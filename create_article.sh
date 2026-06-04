#!/usr/bin/env bash

#if $1 exists, refuse to create article
if [ -d "$1" ]; then
  echo "Directory $1 already exists. Refusing to create article."
  exit 1
fi

mkdir -p "$1"

cp templates/template.typ "$1"/template.typ
touch "$1"/article.typ

cat <<EOL > "$1"/article.typ
#import "template.typ": template

#show: doc => template("Your Title", doc, bibliography_src: none)
EOL