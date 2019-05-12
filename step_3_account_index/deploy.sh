#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

if [ $# -eq 0 ]
then
	echo "This script generates a landing page for a Scrollytelling archive."
	echo
	echo "Pass the account cname you wish to export as paramater."
	echo "Usage: $0 <cname>"
	echo "  e.g. $0 stories.example.com"
	echo
	exit 1
fi

set -vx

root_dir=$HOME/$1

webpack

node-sass ./src/main.scss $root_dir/archive/scrollies.css
postcss --use autoprefixer --output "${root_dir}/archive/archive.css" "${root_dir}/archive/archive.css"
cp dist/bundle.js ${root_dir}/archive
cp images/scrollytelling.png ${root_dir}/archive

mustache "${root_dir}/index.json" ./src/index.html.mustache > "${root_dir}/index.html"
mustache "${root_dir}/index.json" ./src/index.atom.mustache > "${root_dir}/index.atom"
mustache "${root_dir}/index.json" ./src/humans.txt.mustache > "${root_dir}/humans.txt"
