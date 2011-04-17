#
#  AppDelegate.rb
#  StatusCast
#
#  Created by Riccardo Cambiassi on 28/03/2011.
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

class AppDelegate
  attr_accessor :window, :current_status, :statuses_table_view, :destination_popup, :streams_outline, :search_field
  
  def applicationDidFinishLaunching(a_notification)
    account = Account.instance
    if Account.set?
      setupSocialcastApi
      setupMainWindow
    else
      showPreferencesWindow
    end    
  end
  
  def setStatus(sender)
    body = current_status.stringValue
    params = { "message[title]" => "", "message[body]" => "#{body}"}
    destination_index = destination_popup.indexOfSelectedItem
    if destination_index > 0
      destination = destination_popup.selectedItem
      params["message[group_id]"] = destination.id
    end
    reply = @api.add_message(params)
    message = Socialcast::Message.parse(reply)
    current_status.stringValue = ""
    refreshStatusList
  end
  
  def search(sender)
    q = search_field.stringValue
    streams_outline.deselectAll(sender)
    if q == ""
      statuses_table_view.dataSource.set_default_stream
      refreshStatusList
    else
      statuses_table_view.dataSource.set_search(q)
      statuses_table_view.reloadData
    end
  end
  
  def refreshStatusList
    statuses_table_view.dataSource.update_messages
    statuses_table_view.reloadData
  end
  
  def outlineViewSelectionDidChange(notification)
    stream_index = streams_outline.selectedRow
    if stream_index != -1
      selection = streams_outline.itemAtRow(stream_index)
      selection.is_a?(Socialcast::Stream)
      statuses_table_view.dataSource.set_stream(selection)
    else
      statuses_table_view.dataSource.set_default_stream
    end
    refreshStatusList
  end
  
  def showPreferencesWindow(sender=nil)
    NSApplication.sharedApplication.activateIgnoringOtherApps(true)
    PreferencesController.sharedController.showWindow(sender)
  end
  
  
  protected
  
  def setupMainWindow
    @current_status.stringValue = ""
    setupStreams
    setupDestinations
    setupMessages
  end
  
  def setupSocialcastApi
    @account = Account.instance
    Socialcast.configuration do |socialcast|
      socialcast.username = @account.username
      socialcast.password = @account.password
      socialcast.domain   = @account.domain
    end
    @api ||= ::Socialcast.api
  end
  
  def setupStreams
    streams = StreamsController.new(@api)
    streams_outline.delegate=self
    streams_outline.dataSource=streams
    streams.download do |data|
      streams.items = Socialcast::StreamList.parse(data).streams
      streams.update_streams
      streams_outline.reloadData
    end
  end
  
  def setupDestinations
    destinations = DestinationsController.new(@api)
    destination_popup.dataSource = destinations 
    destinations.download do |data|
      groups = Socialcast::GroupMembershipList.parse(data).group_memberships
      destinations.items = Destination.from_socialcast_groups(groups.map {|membership| membership.group })
      destinations.items.unshift Destination.new(0, "My Colleagues")
      destination_popup.reloadData
      destination_popup.selectItemAtIndex 0
    end
  end
  
  def setupMessages
    messages = MessagesController.new(@api)
    statuses_table_view.dataSource = messages
    messages.download do |data|
      socialcast_messages = Socialcast::MessageList.parse(data).messages
      messages.items = Status.from_socialcast_messages(socialcast_messages)
      statuses_table_view.reloadData
    end
    statuses_table_view.delegate= messages
  end
end

