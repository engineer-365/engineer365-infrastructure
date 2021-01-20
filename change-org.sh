#!/bin/bash

#
#  MIT License
#
#  Copyright (c) 2020 engineer365.org
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in all
#  copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#  SOFTWARE.

this_dir=$(cd "$(dirname $0)";pwd)

echo "This script will checkout a new branch then replace example organzation with yours"

read -p "Your organization title (default: 'example') ? " org_title
if [[ "$org_title" == "" ]]; then
  org_title="example"
fi

read -p "Your organization suffix (default: 'com') ? " org_suffix
if [[ "$org_suffix" == "" ]]; then
  org_suffix="com"
fi

read -p "Confirm your organization: (default: ${org_title}.${org_suffix})" org
if [[ "$org" == "" ]]; then
  org="${org_title}.${org_suffix}"
fi

echo "Your orgnization: " "$org"

if [[ "${org}" == "." || "$org" == "example.com" ]]; then
  echo "No change"
  exit 1
fi

function _change_org_in_dir() {
  local old_str=$1
  local new_str=$2
  local local_dir=$3

  grep_cmd="grep ${old_str} -rl ${local_dir} \
           --exclude *.zip \
           --exclude *.gz \
           --exclude *.ovf \
           --exclude *.crt \
           --exclude *.csr \
           --exclude *.p12 \
           --exclude *.pem \
           --exclude *.key \
           --exclude *.png \
           --exclude calico.yaml \
           --exclude tigera-operator.yaml \
           --exclude-dir .git \
           --exclude-dir .vagrant"

  for i in `find ${local_dir}` ;do NN=$(echo $i | sed "s/${old_str}/${new_str}/g") ; if [[ "$NN" != "$i" ]]; then mv "$i" "$NN" ;fi ;done
  
  sed -i "s/${old_str}/${new_str}/g" `${grep_cmd}`
}

function change_org_in_dir() {
  local local_dir=$1

  _change_org_in_dir "example.com" ${org} ${local_dir}
  _change_org_in_dir "example" ${org_title} ${local_dir}
}

function _change_org_in_file() {
  local old_str=$1
  local new_str=$2
  local local_file=$3

  sed -i "s/$old_str}/${new_str}/g" "${local_file}"
}

function change_org_in_file() {
  local local_file=$1

  _change_org_in_file "example.com" ${org} ${local_file}
  _change_org_in_file "example" ${org_title} ${local_file}
}

git checkout -b "${org}"

change_org_in_dir "example.com" "${org}" ${this_dir}/gitlab
change_org_in_dir "example" "${org_title}" ${this_dir}/gitlab

change_org_in_dir ${this_dir}/harbor
change_org_in_dir ${this_dir}/jenkins
change_org_in_dir ${this_dir}/k8s
change_org_in_dir ${this_dir}/mysql
change_org_in_dir ${this_dir}/virtualbox
change_org_in_file ${this_dir}/https/example.com.sh
change_org_in_file ${this_dir}/README.md
