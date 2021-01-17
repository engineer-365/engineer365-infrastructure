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

set -e
set -x

readonly this_dir=$(cd "$(dirname $0)";pwd)

echo "this script will checkout to new branch then replace example organzation with yours"

read -p "Your organization title (e.g. 'example') ? " org_title
read -p "Your organization suffix (e.g. 'com') ? " org_suffix
read -p "Confirm your organization: (${org_title}.${org_suffix})" org

if [ -z "${org}" ]; then
  exit 1
fi

function change_org_in_dir() {
  local local_dir=$1
  local file_pattern=$2 # e.g., "*.html"

  sed -i "s/example.com/${org}/g" \
      `grep "example.com" -rl "${local_dir}" \
           --include "${file_pattern}" \
           --exclude "*.crt" \
           --exclude "*.csr" \
           --exclude "*.p12" \
           --exclude "*.pem" \
           --exclude "*.key" \
           --exclude "*.png" \
           --exclude-dir ".git" \ 
           --exclude-dir ".vagrant"`
}

function change_org_in_file() {
  local local_file=$1

  sed -i "s/example.com/${org}/g" "${local_file}"
}

git checkout -b "${org}"

change_org_in_dir ${this_dir}/gitlab/
change_org_in_dir ${this_dir}/harbor/
change_org_in_dir ${this_dir}/jenkins/
change_org_in_dir ${this_dir}/k8s/
change_org_in_dir ${this_dir}/mysql/
change_org_in_dir ${this_dir}/virtualbox/
