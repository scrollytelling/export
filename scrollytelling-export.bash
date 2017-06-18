#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# This script download an entire Scrollytelling story, media and all.
# Give it the URL of the story as parameter.
# Joost Baaij
# joost@spacebabies.nl

if [ $# -eq 0 ]
then
  echo
  echo "USAGE: `basename $0` <URL to a single Scrollytelling>"
  echo "  e.h. `basename $0` https://app.scrollytelling.io/datwatjenietziet"
  echo
  exit
fi

IFS=/; read -a urlparts <<<"${1#https://}"

domain="${urlparts[0]}"
story="${urlparts[1]}"

mkdir -p $domain
cd $domain

# HTML
wget --adjust-extension --timestamping --no-verbose https://${domain}/${story}

# Entries CSS: find and download, download media, and update the URL
grep -oi '/entries.*css' ${story}.html | xargs -I {} wget 'https://scrollytelling.link'{} --force-directories --timestamping --no-verbose
sed -i '' -e 's,/entries,/scrollytelling.link/entries,g' ${story}.html

# CSS / JS from the asset pipeline
grep -oiE 'https?:\/\/scrollytelling\.link.*?[^?"]+' ${story}.html | xargs wget --force-directories --timestamping --no-verbose
sed -i '' -e 's,https://scrollytelling.link,/scrollytelling.link,g' ${story}.html

# in application JS: search & replace:
# //output.scrollytelling.io
grep -oiE '\/\/output\.scrollytelling\.io.*?[^"]+' scrollytelling.link/assets/pageflow/application*.js | xargs -I {} wget 'https:'\{\} --timestamping --no-verbose --force-directories
sed -i '' -e 's,//output,/output,g' scrollytelling.link/assets/pageflow/application*.js
# //scrollytelling.link
grep -oiE '\/\/scrollytelling\.link.*?[^"]+' scrollytelling.link/assets/pageflow/application*.js | xargs -I {} wget 'https:'\{\} --timestamping --no-verbose --force-directories
sed -i '' -e 's,//scrollytelling.link,/scrollytelling.link,g' scrollytelling.link/assets/pageflow/application*.js

# in application css: search & replace:
# scrollytelling.link
grep -oiE '\/\/scrollytelling\.link.*?[^\)]+' scrollytelling.link/assets/pageflow/application*.css | xargs -I {} wget 'https:'\{\} --timestamping --no-verbose --force-directories
sed -i '' -e 's,//scrollytelling.link,/scrollytelling.link,g' scrollytelling.link/assets/pageflow/application*.css

# font awesome
grep -oiE '\/\/scrollytelling\.link.*?[^?\)]+' scrollytelling.link/assets/pageflow/themes/*.css | xargs -I {} wget 'https:'\{\} --timestamping --no-verbose --force-directories
sed -i '' -e 's,//scrollytelling.link,/scrollytelling.link,g' scrollytelling.link/assets/pageflow/themes/*.css

grep -oiE 'https?:\/\/output\.scrollytelling\.io.*?[^?"]+' ${story}.html | xargs wget --force-directories --timestamping --no-verbose
sed -i '' -e 's,https://output.scrollytelling.io,/output.scrollytelling.io,g' ${story}.html

grep -oiE 'https?:\/\/media\.scrollytelling\.io.*?[^?"]+' ${story}.html | xargs wget --force-directories --timestamping --no-verbose
sed -i '' -e 's,https://media.scrollytelling.io,/media.scrollytelling.io,g' ${story}.html

grep -oiE 'https?:\/\/media\.scrollytelling\.io.*?[^?"]+' scrollytelling.link/entries/${story}.css | xargs wget --force-directories --timestamping --no-verbose
sed -i '' -e 's,https://media.scrollytelling.io,/media.scrollytelling.io,g' scrollytelling.link/entries/${story}.css

# I don't know what idiot thought these files should be generated.
find . -type f -name 'Icon?' -delete

cd -
