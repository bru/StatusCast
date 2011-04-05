#
#  message.rb
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



module Socialcast
  class Message
    attr_accessor :title, :created_at, :id, :body, :source, :permalink, :comments, :user
    
    def initialize(params)
      @title    =  params[:title] || ""
      @id       =  params[:id]
      @body     =  params[:body] || ""
      @source   =  "socialcast"
      @permalink=  params[:permalink_url]
      @created_at= params[:created_at.to_sym]
      @comments =  params[:comments]
      @user     =  params[:user]
      @likes 
    end
    
    def to_hash
      { 
        :title => title,
        :body =>  body,
        :source => source,
        :permalink => permalink,
        :comments => comments,
        :created_at => created_at,
        :id => id
      }
    end
      
    def self.from_xml(xml)
      doc = Nokogiri::XML(xml)
      xml_messages = doc.root.xpath('//messages/message')
      if xml_messages.size == 0 
        xml_messages = doc.root.xpath('//message')
      end
      messages = []
      xml_messages.each do |xml_message|
        comments=[]
        xml_comments=xml_message.xpath('./comments/comment')
        xml_comments.each do |xml_comment|
          likes = []
          xml_likes = xml_comment.xpath('./likes/like')
          xml_likes.each do |xml_like|
            likes << Like.new({
                              :unlikable => xml_like.xpath('./unlikable')[0].text,
                              :id        => xml_like.xpath('./id')[0].text,
                              :created_at=> xml_like.xpath('./created-at')[0].text,
                              :user_id   => xml_like.xpath('./user/id')[0].text,
                              :username   => xml_comment.xpath('./user/username')[0].text
                              })
          end
          comments << Comment.new({
                                  :username   => xml_comment.xpath('./user/username')[0].text,
                                  :user_id    => xml_comment.xpath('./user/id')[0].text,
                                  :text       => xml_comment.xpath('./text')[0].text,
                                  :created_at => xml_comment.xpath('./created-at')[0].text,
                                  :id         => xml_comment.xpath('./id')[0].text,
                                  :likes      => likes
                                  })
        end
        xml_user = xml_message.xpath('./user')
        user = User.new({
                        :username => xml_user.xpath('./username')[0].text,
                        :name => xml_user.xpath('./name')[0].text,
                        :url => xml_user.xpath('./url')[0].text,
                        :avatar => xml_user.xpath('./avatars/square70')[0].text
                        })
        messages << self.new({
                             :title       => xml_message.xpath('./title')[0].text,
                             :created_at  => xml_message.xpath('./created-at')[0].text,
                             :id          => xml_message.xpath('./id')[0].text,
                             :body        => xml_message.xpath('./body')[0].text,
                             :permalink_url   => xml_message.xpath('./permalink-url')[0].text,
                             :comments    => comments,
                             :user        => user
                             })
      end
      return messages
    end
  end
end
