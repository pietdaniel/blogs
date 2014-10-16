#!/bin/bash

echo "# Welcome to the blog" >> temp.html
echo "" >> temp.html

for file in `ls ./ | grep "\.md"`
  do
    html_name=`echo $file | sed -e "s/\.md/\.html/g"`
    name=`echo $file | sed -e "s/\.md//g"`
    out="- [$name](http://piet.us/blog/$html_name)"
    echo $file
    echo $out >> temp.html
  done
mv temp.html index.md
