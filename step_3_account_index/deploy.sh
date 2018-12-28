#!/usr/bin/env zsh
#
## And now! The script!!
set -x

sed -ni '/csrf/!p' ../entries/*/*.html # strip CSRF tokens
sed -ni '/PAGEFLOW_EDITOR/!p' ../entries/*/*.html # strip editor JS
sed -i 's/ data-turbolinks-track="true"//g' ../entries/*/*.html # no turbolinks either

sed -i 's\http://media\media\g' ../entries/**/*.html
sed -i 's\https://media\media\g' ../entries/**/*.html
sed -i 's\http://output\output\g' ../entries/**/*.html
sed -i 's\https://output\output\g' ../entries/**/*.html
sed -i 's\https://scrollytelling.link\scrollytelling.link\g' ../entries/**/*.html
sed -i 's\../scrollytelling.link\scrollytelling.link\g' ../entries/**/*.html
sed -i 's\/media\media\g' ../entries/**/*.css
sed -i 's\/media\media\g' ../entries/**/*.js
sed -i 's\/media\media\g' ../entries/**/*.html

webpack

for account in ../entries/*
do
  node-sass ./src/main.scss "${account}/scrollies.css"
  postcss --use autoprefixer --output "${account}/scrollies.css" "${account}/scrollies.css"
  cp dist/bundle.js ${account}
  mustache "${account}/index.json" ./src/index.html.mustache > "${account}/index.html"
  mustache "${account}/index.json" ./src/index.atom.mustache > "${account}/index.atom"
  mustache "${account}/index.json" ./src/humans.txt.mustache > "${account}/humans.txt"

  cp -r ./_documentroot/* $account
  cp -r ./_scrollytelling.link/* "${account}/scrollytelling.link"
  cp -r ./_output.scrollytelling.com/* "${account}/output.scrollytelling.com"
  # mv "${account}/entries" "${account}/scrollytelling.link"

  # gzip --keep --force $account/**/*.html $account/**/*.json $account/**/*.xml $account/site.webmanifest
  # gzip --keep --force $account/**/*.svg
  # gzip --keep --force $account/humans.txt
done
