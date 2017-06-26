#!/usr/bin/env ruby
require "./llwd_klass"

include Baidu

tr = Trans.new

# check appid and secret_key
tr.check_appid
tr.check_secret_key

# set appid and secret_key
tr.set_appid
tr.set_secret_key

# read ARGV
tr.request_str(ARGV)

# set random salt
tr.request_salt

# sign MD5
tr.request_sign

# send
tr._send_

