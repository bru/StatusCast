#
#  api.rb
#  StatusCast
#
#  Created by Riccardo Cambiassi on 31/03/2011.
#  Copyright (c) 2011, Riccardo Cambiassi
#  All rights reserved.
#  
#  Redistribution and use in source and binary forms, with or without modification, are 
#  permitted provided that the following conditions are met:
#  
#  Redistributions of source code must retain the above copyright notice, this list of 
#  conditions and the following disclaimer.
#  Redistributions in binary form must reproduce the above copyright notice, this list of 
#  conditions and the following disclaimer in the documentation and/or other materials 
#  provided with the distribution.
#  Neither the name of the <ORGANIZATION> nor the names of its contributors may be used to 
#  endorse or promote products derived from this software without specific prior written 
#  permission.
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
#  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
#  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT 
#  SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
#  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
#  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
#  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
#  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
#  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#  


#require 'rubygems'
require 'nokogiri'
require 'net/http'
require 'net/https'
require 'openssl'
require 'uri'
require 'digest/md5'
require 'cgi'



module Socialcast
  class API
    attr_accessor :debug
    
    def initialize(username, password, domain, format="xml",debug=false)
      @debug    = debug
      @username = username
      @password = password
      @format   = format
      @endpoint = "https://#{domain}/api/"
      return self
    end
    
    def messages(stream=nil)
      method="messages"
      method.insert(0, "streams/#{stream.id}/") if stream
      xml = api_get(method)
      return Socialcast::Message.from_xml(xml)
    end
    
    def search(query)
      method="messages/search"
      xml = api_get(method, query)
      return Socialcast::Message.from_xml(xml)
    end
    
    def groups
      method = "group_memberships"
      xml = api_get(method)
      return Socialcast::Group.from_xml(xml)
    end
    
    def streams
      method = "streams"
      xml = api_get(method)
      return Socialcast::Stream.from_xml(xml)
    end
    
    def add_message(message)
      xml = api_post("messages", message)
      return xml
    end
    
    def add_comment(message_id, comment)
      xml = api_post("messages/#{message_id}/comments", comment)
      return xml
    end
    
    def like_comment(message_id,comment_id)
      xml = api_post("messages/#{message_id.to_s}/comments/#{comment_id.to_s}/likes")
      return xml
    end
    
    def unlike_comment(message_id,comment_id,like_id)
      xml = api_delete("messages/#{message_id}/comments/#{comment_id}/likes/#{like_id}")
      return xml
    end
    
    def log(string)
      NSLog "SocialCast API: " + string if @debug
    end
    
    def https_request(method, path, args)
      https = setup_https
      response = ""
      case method
        when 'get'
        request_class = Net::HTTP::Get
        query=args
        when 'post'
        request_class = Net::HTTP::Post
        form_data = args
        when 'put'
        request_class = Net::HTTP::Put
        form_data = args
        when 'delete'
        request_class = Net::HTTP::Delete
      end
      if @debug
        log("Calling #{request_class.to_s} for #{path} with '#{args.map {|k,v| k + ': ' + v }.join(', ')}'")
      end
      https.start do |session|
        query_string = "/api/#{path}.#{@format}"
        query_string += "?" + (query.collect { |k,v| "#{k}=#{CGI::escape(v.to_s)}" }.join('&')) unless query.nil?
        req = request_class.new(query_string)
        req.basic_auth @username, @password
        if form_data
          req.set_form_data(args, ';')
        end
        response = session.request(req).body
      end
      if @debug
        log("Received: #{response}\n\n")
      end
      response  
    end
    
    def api_get(path, args={})
      https_request('get', path, args)
    end   
    
    
    def api_post(path, args={})
      https_request('post', path, args)
    end
    
    def api_delete(path, args={})
      https_request('delete', path, args)
    end
    
    def setup_https
      url   = URI.parse(@endpoint) 
      https = Net::HTTP.new(url.host, url.port)
      https.verify_mode = OpenSSL::SSL::VERIFY_NONE
      https.use_ssl = true
      return https
    end
  end
end
