#!/bin/bash
echo "# Welcome to the blog" >> temp.md
for file in `ls ./ | grep "\.md" | grep -v index.md | grep -v README.md | grep -v temp.md`
  do
    html_name=`echo $file | sed -e "s/\.md/\.html/g"`
    name=`echo $file | sed -e "s/\.md//g"`
    out="- [$name](http://piet.us/blog/$html_name)"
    echo $file
    echo $out >> temp.md
  done
mv temp.md index.md
