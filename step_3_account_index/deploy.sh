#!/usr/bin/env bash
#
## And now! The script!!
set -x

for account in ../entries/*
do
  node-sass ./src/main.scss "${account}/index.css"
  postcss --use autoprefixer --output "${account}/index.css" "${account}/index.css"
  cat ./vendor/*.js ./src/main.js > "${account}/index.js"
  mustache "${account}/index.json" ./src/index.html.mustache > "${account}/index.html"
  mustache "${account}/index.json" ./src/index.atom.mustache > "${account}/index.atom"

  mkdir -p "${account}/scrollytelling.link"
  mkdir -p "${account}/output.scrollytelling.com"
  cp -r ./_documentroot/* $account
  cp -r ./_scrollytelling.link/* "${account}/scrollytelling.link"
  cp -r ./_output.scrollytelling.com/* "${account}/output.scrollytelling.com"

  gzip --keep --force $account/index.*
  gzip --keep --force $account/images/*.png $account/images/*.svg
  gzip --keep --force $account/humans.txt
done
