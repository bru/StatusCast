#
#  messages_controller.rb
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




class MessagesController
  def initialize(api=nil)
    @api = api
    @stream = nil
    update_messages
  end
  
  def update_messages
    @messages = @api.messages(@stream)
  end
  
  def set_stream(stream)
    @stream=stream
  end
  
  def set_default_stream
    set_stream(nil)
  end
  
  def set_search(query)
    @api.debug = true
    @messages = @api.search(:q => query)
    @api.debug = false
  end
  
  def numberOfRowsInTableView(view)
    @messages.size
  end
  
  def tableView(view, objectValueForTableColumn:column, row:index)
    status = @messages[index]
    case column.identifier
    when 'avatar'
      if (status.user && status.user.avatars)
        NSImage.alloc.initByReferencingURL NSURL.URLWithString(status.user.avatars.square70)
      else
        NSImage.imageNamed 'NSUser'
      end
    when 'message'
      user_font  = NSFont.fontWithName("Helvetica", size:11.0)
      user_color = NSColor.purpleColor
      date_font  = NSFont.fontWithName("Helvetica", size: 11.0)
      date_color = NSColor.lightGrayColor
      title_font = NSFont.fontWithName("Helvetica-BoldOblique", size: 11.0)
      user_attributes = { NSFontAttributeName => user_font, NSForegroundColorAttributeName => user_color}
      date_attributes = { NSFontAttributeName => date_font, NSForegroundColorAttributeName => date_color}
      title_attributes = { NSFontAttributeName => title_font }
      

      user_string = NSAttributedString.alloc.initWithString(status.user.name, attributes: user_attributes) if status.user.name
      date_string = NSAttributedString.alloc.initWithString(" on #{DateTime.parse(status.created_at).strftime('%d/%m/%Y %H:%M')}\n", attributes: date_attributes) 
      body_string = NSAttributedString.alloc.initWithString(status.body) if status.body
      title_string = NSAttributedString.alloc.initWithString("#{status.title}\n", attributes: title_attributes) if status.title
      
#      NSLog("About to add object with:\n#{user_string ? user_string.string : "NO USER"}\n#{date_string ? date_string.string : "NO DATE"}\n#{body_string ? body_string.string : "NO BODY" }\n#{title_string ? title_string.string : "NO TITLE"}")
      message_string = NSMutableAttributedString.alloc.initWithString("")
      message_string.appendAttributedString(user_string) if user_string
      message_string.appendAttributedString(date_string) if date_string
      message_string.appendAttributedString(title_string) if title_string
      message_string.appendAttributedString(body_string) if body_string
      return message_string
    end
  end
  
end
