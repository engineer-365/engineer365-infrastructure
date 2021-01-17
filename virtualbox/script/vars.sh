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

log_info "---------------------------------------------------------------------"
log_info "Variables:"

export readonly org="example.com"
log_info "\t  org:" ${org}

export readonly download_site="https://download.engineer365.org:40443"
log_info "\t  download_site:" ${download_site}

export readonly scp_upload_path="192.168.4.2:/hdd/engineer365/download/vagrant/box/${org}"
log_info "\t  scp_upload_path:" ${scp_upload_path}

export readonly scp_upload_port="30022"
log_info "\t  scp_upload_port:" ${scp_upload_port}

export readonly box_download_path="${download_site}/vagrant/box"
log_info "\t  box_download_path:" ${box_download_path}


# users
export readonly admin_user="admin"
log_info "\t  admin_user:" ${admin_user}

export readonly dev_user="dev"
log_info '\t  dev_user:' ${dev_user}

log_info "---------------------------------------------------------------------"
