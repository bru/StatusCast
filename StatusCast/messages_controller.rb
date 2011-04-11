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
    @messages = Status.from_socialcast_messages(@api.messages(@stream))
  end
  
  def set_stream(stream)
    @stream=stream
  end
  
  def set_default_stream
    set_stream(nil)
  end
  
  def set_search(query)
    @messages = Status.from_socialcast_messages(@api.search(:q => query))
  end
  
  def numberOfRowsInTableView(view)
    @messages.size
  end

  def tableView(view, willDisplayCell:cell, forTableColumn:column, row:row)
    case column.identifier
    when 'avatar'
      if cell.image.name == "NSUser"
        status = @messages[row]
        status.download do |data|
          NSLog("Loaded image for avatar on row #{row.to_s}")
          status.image = NSImage.alloc.initWithData data
          view.reloadDataForRowIndexes NSIndexSet.indexSetWithIndex(row), columnIndexes:NSIndexSet.indexSetWithIndex(0)
        end
      end
    end
  end
  
  def tableView(view, objectValueForTableColumn:column, row:row)
    status = @messages[row]
    status.send column.identifier, column.dataCellForRow(row)
  end

  def tableView(view, shouldTrackCell:cell, forTableColumn:column, row:index)
    true
  end
  
  
end
