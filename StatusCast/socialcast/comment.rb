#
#  comment.rb
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
  class Comment
    attr_accessor :username, :user_id, :created_at, :id, :text, :likes
    
    def initialize(params={})
      @username =  params[:username]
      @user_id  =  params[:user_id]
      @id       =  params[:id]
      @text     =  params[:text]
      @created_at= params[:created_at]
      @likes    =  params[:likes]
    end
    
    def unlikable_by?(api_id)
      self.likes.map{|l| l.unlikable_by?(api_id)}.any?
    end
    
    def likable_by?(api_id)
      self.user_id  != api_id
    end
    
    def like_id(api_id)
      self.likes.select { |like| like.unlikable_by?(api_id) }.first.id
    end
  end
end
