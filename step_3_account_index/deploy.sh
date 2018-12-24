#!/usr/bin/env bash
#
## And now! The script!!
set -x

for account in ../entries/*
do
  node-sass ./src/main.scss "${account}/scrollies.css"
  postcss --use autoprefixer --output "${account}/scrollies.css" "${account}/scrollies.css"
  webpack && cp dist/bundle.js ${account}
  mustache "${account}/index.json" ./src/index.html.mustache > "${account}/index.html"
  mustache "${account}/index.json" ./src/index.atom.mustache > "${account}/index.atom"
  mustache "${account}/index.json" ./src/humans.txt.mustache > "${account}/humans.txt"

  cp -r ./_documentroot/* $account
  cp -r ./_scrollytelling.link/* "${account}/scrollytelling.link"
  cp -r ./_output.scrollytelling.com/* "${account}/output.scrollytelling.com"
  mv "${account}/entries" "${account}/scrollytelling.link"

  # Replace all old URIs in everything we can find.
  find ${account} -type f -print0 | xargs -0 sed -i -e 's\http://media\media\g'
  find ${account} -type f -print0 | xargs -0 sed -i -e 's\http://output\output\g'
  find ${account} -type f -print0 | xargs -0 sed -i -e 's\https://scrollytelling.link\scrollytelling.link\g'
  find ${account} -type f -print0 | xargs -0 sed -i -e 's\../scrollytelling.link\scrollytelling.link\g'
  find ${account} -type f -print0 | xargs -0 sed -i -e "s\https://hu.scrollytelling.io/images\images\g"

  gzip --keep --force $account/index.html $account/index.json $account/browserconfig.xml $account/site.webmanifest
  gzip --keep --force $account/images/*.png $account/images/*.svg
  gzip --keep --force $account/humans.txt
done
