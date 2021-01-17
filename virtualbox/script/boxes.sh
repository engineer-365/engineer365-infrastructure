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

opt_clean='false'
opt_interactive='false'
opt_upload='false'
opt_verbose='false'
opt_size='mini'

# parse options
# begin -----------------------------------------------------------------------

ARGS=`getopt -o chiuvs:: --long clean,help,interactive,upload,verbose,size:: -n "$0" -- "$@"`
if [ $? != 0 ]; then
  exit 1
fi

eval set -- "${ARGS}"

function usage() {
  echo ""
  echo "Usage:"
  echo "  $0 [options]"

  echo ""
  echo "Examples:"
  echo "  1) build clean box:         $0 --clean"
  echo "  2) build full-size cluster: $0 --size=full"

  echo ""
  echo "Options:"
  echo "  -c, --clean                 Clean exiting box"
  echo "  -h, --help                  Display this help"
  echo "  -i, --interactive           Allow to ssh into box under building"
  echo "  -u, --upload                Upload box; please check vars.sh for where to upload"
  echo "  -v, --verbose               Make the operation more talkative"
  echo "  -s, --size=[mini|mid|full]  Cluster size; default is 'mini'"
  echo ""
}

while true
do
  case "$1" in
    -c|--clean) 
      opt_clean='true'
      shift
      ;;
    -h|--help) 
      usage
      exit 0
      ;;
    -i|--interactive) 
      opt_interactive='true'
      shift
      ;;
    -u|--upload) 
      opt_upload='true'
      shift
      ;;
    -v|--verbose) 
      opt_verbose='true'
      shift
      ;;
    -s|--size)
      case "$2" in
        "")
          opt_size='mini'
          shift 2  
          ;;
        *)
          opt_size="$2"
          shift 2;
          ;;
      esac
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Internal error!"
      usage
      exit 1
      ;;
  esac
done

case "${opt_size}" in
  "mini"|"mid"|"full")
    ;;
  *)
    echo "Invalid 'size' option value: '${opt_size}'. It must be 'mini', 'mid', or 'full'"
    usage
    exit 1
    ;;
esac
# end -------------------------------------------------------------------------

# print the options 
# begin -----------------------------------------------------------------------
echo "option values:"

echo "    clean:" $opt_clean
export opt_clean

echo "    interactive:" $opt_interactive
export opt_interactive

echo "    upload:" $opt_upload
export opt_upload

echo "    verbose:" $opt_verbose
export opt_verbose

if [ ${opt_verbose} == "true" ]; then
  set -x
else
  set +x
fi

echo "    size:" $opt_size
export opt_size

# end -------------------------------------------------------------------------


if [ -z $script_dir ]; then
  script_dir=$(cd "./script";pwd)
fi
echo "script directory::" $script_dir
export script_dir

export virtualbox_dir=$(dirname $script_dir)
echo "virtualbox directory::" $virtualbox_dir
export virtualbox_dir


source ${script_dir}/vars.sh
source ${script_dir}/ip_and_host.sh
source ${script_dir}/box_name.sh


function up_vm() {
    import_box $1
    vagrant up
}

function import_raw_box() {
    local org_name=$1
    local box_name=$2
    local box_name_fq="${org_name}/${box_name}"

    vagrant box list | grep "${box_name_fq}" | wc -l > ${box_name}.box.counter
    if [ "$(cat ${box_name}.box.counter)" != '1' ]; then
        echo "box ${box_name_fq} not found, importing ..."

        download_box ${org_name} ${box_name}
    else
        echo "box ${box_name_fq} exists already"

        if [ ${opt_clean} == "true" ]; then
            echo "option 'clean' is 'true', so remove the existing box: ${box_name_fq}"            
            vagrant box remove "${box_name_fq}"

            download_box ${org_name} ${box_name}
        fi
    fi

    rm ${box_name}.box.counter
}


function download_box() {
    local org_name=$1
    local box_name=$2
    local box_name_fq="${org_name}/${box_name}"
    
    local box_file="${box_name}.box"
    rm -f ${box_file}
    
    local download_path="${box_download_path}/${org_name}/${box_file}"
    echo "downloading box ${box_name_fq} from ${download_path}"
    wget --quiet "${download_path}"

    vagrant box add ${box_file} --name "${box_name_fq}" --force
    rm ${box_file}
}

function import_box() {
    local box_name=$1
    local box_name_fq="${org}/${box_name}"

    import_raw_box ${org} ${box_name} ${clean}
}


function build_box() {
    set -e

    local box_name=$1
    local box_name_fq="${org}/${box_name}"
    local box_file="${box_name}.box"

    vagrant halt
    vagrant destroy --force
  
    vagrant up

    if [ ${opt_interactive} == "true" ]; then
      vagrant ssh
    fi

    rm -f ${this_dir}/${box_file}
    vagrant package --output ${this_dir}/${box_file}

    vagrant box add ${this_dir}/${box_file} --name ${box_name_fq} --force

    vagrant halt
    vagrant destroy --force
    rm -rf ${this_dir}/.vagrant

    if [ ${opt_clean} == "true" ]; then
      echo 'uploading box'
      scp -P ${scp_upload_port} -o StrictHostKeyChecking=no ${this_dir}/${box_file} ${scp_upload_path}
    fi
}


