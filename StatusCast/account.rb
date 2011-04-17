#
#  account.rb
#  StatusCast
#
#  Created by Riccardo Cambiassi on 15/04/2011.
#  Copyright 2011 __MyCompanyName__. All rights reserved.
#
require 'singleton'

class Account
  include Singleton
  ATTRIBUTES = [:domain, :username, :password, :interval]
  attr_accessor *ATTRIBUTES
  
  def defaults
    { :username => "Username",
      :password => "Password",
      :domain   => "domain.socialcast.com",
      :interval => "2 minutes"
    }
  end
  
  def initialize
    @username = config[:username]
    @password = config[:password]
    @domain   = config[:domain]
    @interval = config[:interval]
  end
  
  def self.set?
    instance.user_defaults.nil? ? false : true
  end

  def key
    'socialcast.account'
  end

  def user_defaults
    NSUserDefaults.standardUserDefaults[key]
  end

  def set_user_defaults(value)
    NSUserDefaults.standardUserDefaults[key] = value
    NSUserDefaults.standardUserDefaults.synchronize

  end
  
  def config
    user_defaults || defaults
  end
    
  
  def save
    set_user_defaults(to_hash)
  end
  
  def to_hash
    { :username => @username,
      :password => @password,
      :domain   => @domain,
      :interval => @interval
    }
  end
end