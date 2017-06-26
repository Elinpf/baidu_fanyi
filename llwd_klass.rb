#!/usr/bin/env ruby

require "digest/md5"
require "net/http"
require "uri"
require "json"

require "./config"

module Baidu
	class Trans
		attr_reader :http, :md5, :encode, :myurl
		attr_accessor :appid, :secret_key, :from, :to
		attr_accessor :q, :salt, :sign
		def initialize
			@http = Net::HTTP.new("api.fanyi.baidu.com")
			@md5  = ::Digest::MD5.method(:hexdigest)
			@encode = URI.method(:encode)
			@myurl  = '/api/trans/vip/translate'
			
			@from = Config::From_lang
			@to		= Config::To_lang
		end

		def help
			puts "Usage: lwd [TEXT]"
			puts "	-h, --help         show help"
			puts "	-                  STDIN"
			exit 1
		end
			
		def check_appid
			if Config::Appid.empty? || Config::Appid.nil?
				puts "Please input Appid in config.rb"
				exit 1
			end
			true
		end

		def check_secret_key
			if Config::Secret_key.empty? || Config::Secret_key.nil?
				puts "Please input Secret_key in config.rb"
				exit 1
			end
			true
		end

		def set_appid
			check_appid
			@appid = Config::Appid
		end

		def set_secret_key
			check_secret_key
			@secret_key = Config::Secret_key
		end

		def request_str(args=[])
			if args.empty? 
				help
			elsif args[0] == '-h' or args[0] == '--help'
				help
			elsif args.size == 1 && args[0] == '-'
				@q = $stdin.read
			else
			  @q = args.join(' ')
			end
		end

		def check_wudao
			reg_on = /No such word: (.*) found online/
			reg_off = /Error: no such word :(.*)\nYou can use -o to search online./
			if @q =~ reg_on or @q =~ reg_off
				@q = $1
			end
		end

		def request_salt
			@salt = rand(32768..65536).to_s
		end

		def request_sign
			s = ""
			s << appid
			s << q
			s << salt
			s << secret_key
			@sign = md5.call(s)
		end

		def request_myurl
			url = ""
			url << myurl
			url << '?appid=' + appid
			url << '&q=' + @encode.call(@q)
			url << '&from=' + @from
			url << '&to=' + @to
			url << '&salt=' + salt
			url << '&sign=' + @sign
			url
		end

		def reply_check(hah)
			if hah['error_code']
				reply_error(hah)
			else
				reply_dst(hah)
			end
		end

		def reply_dst(hah)
			puts hah['trans_result'].first['dst']
		end

		def reply_error(hah)
			case hah['error_code']
			when "52001"
				puts "ERROR: 请求超时，请重试"
			when "52002"
				puts "ERROR: 系统错误，请重试"
			when "52003"
				puts "ERROR: 检查您的appid是否正确"
			else
				puts "#{hah['error_code']}: #{hah['error_msg']}"
			end
		end

		def _send_
			begin
				res = @http.get(request_myurl)
				body = res.body
				trans = JSON.parse(body)
				reply_check(trans)
			rescue => e
				puts e
				puts caller
			end
		end
	end
end
