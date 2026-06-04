#!/usr/bin/env bash

rm -rf publish

mkdir -p publish

sed '1s/.*/#let page_width = {{width}}/;2s/.*/#let dark = {{darkmode}}/' template.typ > publish/template.typ
cp Material-Theme.tmTheme publish/Material-Theme.tmTheme

cd publish
zip template.zip template.typ Material-Theme.tmTheme

cp ./template.zip ../../publish/template.zip