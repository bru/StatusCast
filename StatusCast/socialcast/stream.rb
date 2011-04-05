#
#  stream.rb
#  StatusCast
#
#  Created by Riccardo Cambiassi on 03/04/2011.
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



module Socialcast
  class Stream
    attr_accessor :username, :name, :url, :avatar, :id, :group
    
    def initialize(params={})
      @id     = params[:id]
      @name   = params[:name]
      @url    = params[:url]
      @avatar = params[:avatar]
      @group  = params[:group] if params[:group]
    end
    
    def self.from_xml(xml)
    doc = Nokogiri::XML(xml)
    streams = []
    streams_xml = doc.xpath('//streams/stream')
    streams_xml.each do |stream_xml|
      group = Group.from_dom(stream_xml.xpath('./group')) if stream_xml.xpath('./group').any?
      streams << self.new({
        :id         => stream_xml.xpath('./id')[0].text,
        :name       => stream_xml.xpath('./name')[0].text,
        :default    => stream_xml.xpath('./default')[0].text,
        :custom_stream    =>  stream_xml.xpath('./custom-stream')[0].text,
        :group      => group || nil
      })
  end
  return streams
end

end
end
