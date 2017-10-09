#!/bin/bash
set -e

# Scrollytelling
# www.scrollytelling.io
#
# This script downloads an entire Scrollytelling story: code and all content.
# It organises a local folder so that it works out of the box. Chuck it on any webserver.
#
# The URL to the story is given as parameter on the command line.
# Joost Baaij
# joost@spacebabies.nl

if [ $# -eq 0 ]
then
  echo
  echo "USAGE: `basename $0` <URL to a single Scrollytelling>"
  echo "  e.g. `basename $0` https://app.scrollytelling.io/datwatjenietziet"
  echo
  echo "The environment variable BUCKET needs to be set to the output bucket on S3."
  exit
fi

: "${BUCKET:?}"

echo "# parse domain and path parts from the first command line argument"
IFS=/; read -a urlparts <<<"${1#https://}"
domain="${urlparts[0]}"
story="${urlparts[1]}"

shopt -s expand_aliases
alias _sed="sed -E -i '.orig' -e "
alias _xargs="gxargs -I {} --no-run-if-empty"

echo "# HTML, the entry to everything. Also creates the proper dir."
wget --force-directories --timestamping --no-verbose --adjust-extension "$1"
cd $domain

echo "# Entries CSS: find and download, download media, and update the URL"
grep -oi '/entries.*css' ${story}.html | _xargs wget --force-directories --timestamping --no-verbose 'https://scrollytelling.link{}'
_sed 's,\/entries,\/scrollytelling\.link\/entries,g' "${story}.html"

echo "# CSS / JS from the asset pipeline"
grep -oiE 'https?:\/\/scrollytelling\.link.*?[^?"]+' ${story}.html | _xargs wget --force-directories --timestamping --no-verbose '{}'
_sed 's,https?:\/\/scrollytelling\.link,\/scrollytelling\.link,g' "${story}.html"

echo "# in application JS: search & replace:"
echo "# //output.scrollytelling.io"
grep -oiE '\/\/output\.scrollytelling\.io.*?[^"]+' scrollytelling.link/assets/pageflow/application*.js | _xargs wget --force-directories --timestamping --no-verbose 'https:{}'
_sed 's,\/\/output,\/output,g' scrollytelling.link/assets/pageflow/application*.js
echo "# //scrollytelling.link"
grep -oiE '\/\/scrollytelling\.link.*?[^"]+' scrollytelling.link/assets/pageflow/application*.js | _xargs wget --force-directories --timestamping --no-verbose 'https:{}'
_sed 's,\/\/scrollytelling\.link,\/scrollytelling\.link,g' scrollytelling.link/assets/pageflow/application*.js

echo "# in application css: search & replace:"
echo "# scrollytelling.link"
grep -oiE '\/\/scrollytelling\.link.*?[^\)]+' scrollytelling.link/assets/pageflow/application*.css | _xargs wget --force-directories --timestamping --no-verbose 'https:{}'
_sed 's,\/\/scrollytelling\.link,\/scrollytelling\.link,g' scrollytelling.link/assets/pageflow/application*.css

echo "# font awesome"
grep -oiE '\/\/scrollytelling\.link.*?[^?\)]+' scrollytelling.link/assets/pageflow/themes/*.css | _xargs wget --force-directories --timestamping --no-verbose 'https:{}'
_sed 's,\/\/scrollytelling\.link,\/scrollytelling\.link,g' scrollytelling.link/assets/pageflow/themes/*.css

echo "# zencoder output from the story HTML"
grep -oiE 'https?:\/\/output\.scrollytelling\.io.*?[^?"]+' ${story}.html | grep -v ":id" | _xargs wget --force-directories --timestamping --no-verbose '{}'
_sed 's,https?:\/\/output\.scrollytelling\.io,\/output\.scrollytelling\.io,g' ${story}.html

echo "# media from the story HTML"
grep -oiE "https?:\/\/media\.scrollytelling\.io.*?[^?\"']+" ${story}.html | grep -v ":id" | _xargs wget --force-directories --timestamping --no-verbose '{}'
_sed 's,https?:\/\/media\.scrollytelling\.io,\/media\.scrollytelling\.io,g' ${story}.html

echo "# media from the story CSS"
grep -oiE "https?:\/\/media\.scrollytelling\.io.*?[^?\"']+" scrollytelling.link/entries/${story}.css | _xargs wget --force-directories --timestamping --no-verbose '{}'
_sed 's,https?:\/\/media\.scrollytelling\.io,\/media\.scrollytelling\.io,g' scrollytelling.link/entries/${story}.css

echo "# sync all the output directories using AWS CLI"
cd output.scrollytelling.io
types=(video_files audio_files)
for type in "${types[@]}"
do
  folders=(v1/main/pageflow/$type/*/*/*)
  for folder in "${folders[@]}"
  do
    aws s3 sync "s3://${BUCKET}/${folder}" "${folder}"
  done
done
cd -

# I don't know what idiot thought these files should be generated.
find . -type f -name 'Icon?' -delete
find . -type f -name '.DS_Store' -delete

cd -
