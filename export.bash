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
  exit
fi

echo "# parse domain and path parts from the first command line argument"
IFS=/ read -a urlparts <<<"${1#https://}"
domain="${urlparts[0]}"
story="${urlparts[1]}"

shopt -s expand_aliases
alias _sed="sed --regexp-extended --in-place='.orig' -e "
alias _xargs="xargs --no-run-if-empty"

echo "# HTML, the entry to everything. Also creates the proper dir."
wget --force-directories --timestamping --no-verbose --adjust-extension "$1"
cd $domain

echo "# Entries CSS: find and download, download media, and update the URL"
grep -oi '/entries.*css' ${story}.html | _xargs -I% wget --force-directories --timestamping --no-verbose "https://scrollytelling.link%"
_sed 's,\/entries,\/scrollytelling\.link\/entries,g' "${story}.html"

echo "# CSS / JS from the asset pipeline"
grep -oiE "https?:\/\/scrollytelling\.link[^\"']*" ${story}.html | _xargs -L1 wget --force-directories --timestamping --no-verbose
_sed 's,https?:\/\/scrollytelling\.link,\/scrollytelling\.link,g' "${story}.html"

echo "# in application JS: search & replace:"
echo "# //output.scrollytelling.io"
grep -oiE '\/\/output\.scrollytelling\.io[^"]*' scrollytelling.link/assets/pageflow/application*.js | _xargs -I % wget --force-directories --timestamping --no-verbose 'https:%'
_sed 's,\/\/output,\/output,g' scrollytelling.link/assets/pageflow/application*.js
echo "# //scrollytelling.link"
grep -oiE '\/\/scrollytelling\.link[^"]*' scrollytelling.link/assets/pageflow/application*.js | _xargs -I % wget --force-directories --timestamping --no-verbose 'https:%'
_sed 's,\/\/scrollytelling\.link,\/scrollytelling\.link,g' scrollytelling.link/assets/pageflow/application*.js

echo "# in application css: search & replace:"
echo "# scrollytelling.link"
grep -oiE '\/\/scrollytelling\.link[^\)]*' scrollytelling.link/assets/pageflow/application*.css | _xargs -I % wget --force-directories --timestamping --no-verbose 'https:%'
_sed 's,\/\/scrollytelling\.link,\/scrollytelling\.link,g' scrollytelling.link/assets/pageflow/application*.css

echo "# font awesome"
grep -oiE '\/\/scrollytelling\.link[^?\)]*' scrollytelling.link/assets/pageflow/themes/*.css | _xargs -I % wget --force-directories --timestamping --no-verbose 'https:%'
_sed 's,\/\/scrollytelling\.link,\/scrollytelling\.link,g' scrollytelling.link/assets/pageflow/themes/*.css

echo "# all files used in the story"
wget "https://app.scrollytelling.io/editor/entries/${story}/files/video_files.json" | jq ".[] | select(.url)"
wget "https://app.scrollytelling.io/editor/entries/${story}/files/audio_files.json"
wget "https://app.scrollytelling.io/editor/entries/${story}/files/image_files.json"
wget "https://app.scrollytelling.io/editor/entries/${story}/files/text_track_files.json"

echo "# globally replace CDN media urls with local paths"
find . -type f -print0| xargs -0 sed -i 's/https:\/\/media/media/g'

echo "# globally replace CDN output urls with local paths"
find . -type f -print0| xargs -0 sed -i 's/https:\/\/output/output/g'

cd -
