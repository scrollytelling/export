#!/usr/bin/env bash
#
## And now! The script!!
set -x

for account in ../entries/*
do
  node-sass _sass/main.scss "${account}/css/main.css"
  postcss --use autoprefixer --output "${account}/css/main.css" "${account}/css/main.css"
  pug --obj "${account}/index.json" --pretty --out $account index.pug

  mkdir -p "${account}/scrollytelling.link"
  mkdir -p "${account}/output.scrollytelling.com"
  cp -r ./_documentroot/* $account
  cp -r ./_scrollytelling.link/* "${account}/scrollytelling.link"
  cp -r ./_output.scrollytelling.com/* "${account}/output.scrollytelling.com"

  gzip --keep --force $account/css/main.css
  gzip --keep --force $account/js/*.js
  gzip --keep --force $account/images/*
  gzip --keep --force $account/humans.txt
  gzip --keep --force $account/index.html
done
