#
#  streams_controller.rb
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



class StreamsController
  attr_accessor :items
  
  def initialize(api)
    @api = api
    @items = @api.streams
    @streams = []
    @streams << { key: "Activity Streams", value: @items.select { |item| item.group.nil? } }
    @streams << { key: "Groups", value:  @items.reject { |item| item.group.nil? } }
  end
  
  def outlineView(view, numberOfChildrenOfItem:item)
    return @streams.size if item.nil?
    return item[:value].count unless item.is_a? Socialcast::Stream
    return 0
  end
  
  def outlineView(view, isItemExpandable:item)
    item.is_a?(Socialcast::Stream) ? false : true
  end
  
  # Return the actual child, not the data that will be used for display.
  def outlineView(view, child:index, ofItem:item)
    return @streams[index] if item.nil?
    return item[:value][index] unless item.is_a?(Socialcast::Stream)
    return nil
  end
  
  # Get the displayable value from the actual child node.
  def outlineView(view, objectValueForTableColumn:tableColumn, byItem:item)
    item.is_a?(Socialcast::Stream) ? item.name : item[:key]
  end
end
