#
#  PreferencesController.rb
#  StatusCast
#
#  Created by Riccardo Cambiassi on 14/04/2011.
#  Copyright 2011 __MyCompanyName__. All rights reserved.
#
class PreferencesController < NSWindowController
  attr_accessor :interval, :username, :password, :domain, :ok_button, :cancel_button

  def self.sharedController
    unless @sharedInstance
      @sharedInstance = self.alloc.initWithAccount(Account.instance)
    end
    @sharedInstance
  end

  def initWithAccount(account)
    initWithWindowNibName("Preferences")
    @account = account
    self
  end
   
  def awakeFromNib
    @interval.removeAllItems
    Interval.all.each do |interval|
      @interval.addItemWithTitle(interval.label)
    end
    
    @interval.selectItemWithTitle(@account.interval.to_s || "1 minute")
    @username.setTitleWithMnemonic(@account.username)
    @password.setTitleWithMnemonic(@account.password)
    @domain.setTitleWithMnemonic(@account.domain)
    
  end
  
  def showWindow(sender)
    self.window.center
    super
  end

  def soundSelected(sender)
    @account.interval = @interval.selectedItem.title
  end
  
  def cancel(sender)
     close
  end
  
  def okay(sender)
    @account.interval = @interval.selectedItem.title
    @account.username = @username.stringValue
    @account.password = @password.stringValue
    @account.domain   = @domain.stringValue
    @account.save
    
    close
  end
  
end
