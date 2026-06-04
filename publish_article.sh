#!/usr/bin/env bash

#if $1 does not exist, refuse to publish article
if [ ! -d "$1" ]; then
  echo "Directory $1 does not exist. Refusing to publish article."
  exit 1
fi

if [ ! -d "publish" ]; then
  mkdir publish
fi

if [ -d "publish/$1.zip" ]; then
  rm "publish/$1.zip"
fi

find "$1" -type f ! -name "._*" ! -name "template.typ" -exec zip -j -X "publish/$1.zip" {} \;