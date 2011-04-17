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
  attr_accessor :items
  include ::AsyncXMLDownloader
  
  def initialize(api=nil)
    @api = api
    @items = []
    @stream = nil
    @heights = []
    set_url(messages_url, @api.username, @api.password)
  end
  
  def messages_url
    stream_path = "streams/#{stream.id}/" if @stream
    "#{@api.endpoint}#{stream_path}messages.xml"
  end
  
  def update_messages
    @items = Status.from_socialcast_messages(@api.messages(@stream))
  end
  
  def set_stream(stream)
    @stream=stream
  end
  
  def set_default_stream
    set_stream(nil)
  end
  
  def set_search(query)
    @items = Status.from_socialcast_messages(@api.search(:q => query))
  end
  
  def numberOfRowsInTableView(view)
    @items.size
  end

  def tableView(view, willDisplayCell:cell, forTableColumn:column, row:row)
    case column.identifier
    when 'avatar'
      if cell.image.name == "NSUser"
        status = @items[row]
        status.download do |data|
          status.image = NSImage.alloc.initWithData data
          view.reloadDataForRowIndexes NSIndexSet.indexSetWithIndex(row), columnIndexes:NSIndexSet.indexSetWithIndex(0)
        end
      end
    end
  end
  
  def tableView(view, objectValueForTableColumn:column, row:row)
    status = @items[row]
    status.send column.identifier, column.dataCellForRow(row)
  end

  def tableView(view, shouldTrackCell:cell, forTableColumn:column, row:index)
    true
  end
  
  def tableView(view, heightOfRow:row)
    return @heights[row] unless @heights[row].nil?
    
    text_column = view.tableColumnWithIdentifier("text")
    text_width = text_column.width

    message_height = 0
    if @items[row] && @items[row].formatted_message
      message = @items[row].formatted_message
      cell = NSTextFieldCell.new
      cell.setObjectValue message
      cell.setWraps true
      
      size = CGSize.new
      size.width = text_width
      size.height = 10000
      rect = CGRect.new
      rect.size = size
      
      message_height = cell.cellSizeForBounds(rect).height
    end
    #if @items[row] && @items[row].formatted_message 
    #  height = @items[row].formatted_message.size.height.floor
    #  NSLog("found row with size #{height}")
    #end
    @heights[row] = [message_height.floor, 75].max
    return @heights[row]
  end
  
  
end
