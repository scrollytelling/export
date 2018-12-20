#!/usr/bin/env bash
#
## And now! The script!!
set -x

for account in ../entries/*
do
  node-sass _sass/main.scss "${account}/css/main.css"
  postcss --use autoprefixer --output "${account}/css/main.css" "${account}/css/main.css"
  cp -r ./documentroot/* $account
  pug --obj "${account}/index.json" --pretty --out $account index.pug

  gzip --keep --force $account/css/main.css
  gzip --keep --force $account/js/*.js
  gzip --keep --force $account/humans.txt
  gzip --keep --force $account/index.html
done
