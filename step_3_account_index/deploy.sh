#!/usr/bin/env bash
#
## And now! The script!!
set -x

for account in ../entries/*
do
  # trim useless and/or potentially troublesome things from each html
  find ${account} -name *.html -print0 | xargs -0 sed -i -e "5,9d;13,14d"
  find ${account} -name *.html -print0 | xargs -0 sed -i -e 's/ data-turbolinks-track="true"//g' 

  node-sass ./src/main.scss "${account}/scrollies.css"
  postcss --use autoprefixer --output "${account}/scrollies.css" "${account}/scrollies.css"
  webpack && cp dist/bundle.js ${account}
  mustache "${account}/index.json" ./src/index.html.mustache > "${account}/index.html"
  mustache "${account}/index.json" ./src/index.atom.mustache > "${account}/index.atom"
  mustache "${account}/index.json" ./src/humans.txt.mustache > "${account}/humans.txt"

  cp -r ./_documentroot/* $account
  cp -r ./_scrollytelling.link/* "${account}/scrollytelling.link"
  cp -r ./_output.scrollytelling.com/* "${account}/output.scrollytelling.com"
  # mv "${account}/entries" "${account}/scrollytelling.link"

  # Replace all old URIs in everything we can find.
  find ${account} -type f -print0 | xargs -0 sed -i -e 's\http://media\media\g'
  find ${account} -type f -print0 | xargs -0 sed -i -e 's\https://media\media\g'
  find ${account} -type f -print0 | xargs -0 sed -i -e 's\http://output\output\g'
  find ${account} -type f -print0 | xargs -0 sed -i -e 's\https://output\output\g'
  find ${account} -type f -print0 | xargs -0 sed -i -e 's\https://scrollytelling.link\scrollytelling.link\g'
  find ${account} -type f -print0 | xargs -0 sed -i -e 's\../scrollytelling.link\scrollytelling.link\g'
  find ${account} -type f -print0 | xargs -0 sed -i -e "s\https://hu.scrollytelling.io/images\images\g"

  gzip --keep --force $account/**/*.html $account/**/*.json $account/**/*.xml $account/site.webmanifest
  gzip --keep --force $account/**/*.svg
  gzip --keep --force $account/humans.txt
done
