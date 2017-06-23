#/usr/bin/env ruby


require "digest/md5"
require "net/http"
require "uri"
require "json"


http = Net::HTTP.new("api.fanyi.baidu.com")
md5 = ::Digest::MD5.method(:hexdigest)
encode = URI.method(:encode)

appid = '20161117000032016'
secret_key = '2wsk5ZeESDgF6_3GoOIZ'

myurl = '/api/trans/vip/translate'
q = 'apple is my'
from_lang = 'en'
to_lang = 'zh'
salt = rand(32768..65536)

sign = appid + q + salt.to_s + secret_key
sign = md5.call(sign)

myurl = myurl +
				'?appid=' + appid +
				'&q=' + encode.call(q) +
				'&from=' + from_lang +
				'&to=' + to_lang +
				'&salt=' + salt.to_s +
				'&sign=' + sign

begin
	res = http.get(myurl)
	body = res.body
	trans = JSON.parse(body)

	puts res.code
	puts res.message
	puts trans
	if trans["error_code"]
		puts trans["error_msg"]
	else
		puts trans["trans_result"].first["dst"]
	end

rescue => e
	puts e
end

