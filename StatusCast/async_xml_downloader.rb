module AsyncXMLDownloader

  def set_url(absolute_url, username=nil, password=nil)
    if username && password
      @credential = NSURLCredential.credentialWithUser(username, :password => password, :persistence => NSURLCredentialPersistenceNone)
    end
    @url = NSURL.URLWithString absolute_url
  end
  
  def download(&block)
    return unless source_url
    return if loading?
    loading!
    @block = block
    @data = NSMutableString.new
    
    
    request = NSURLRequest.requestWithURL(source_url)
    connection = NSURLConnection.alloc.initWithRequest request, delegate:self, startImmediately:true
    unless connection
      NSLog("URL connection FAILED - #{@url} :(")
    end
  end
  
  def loading?
    @loading ||= false
  end
  
  def loading!
    @loading = true
  end
  
  def stop_loading!
    @loading = false
  end
  
  def source_url
    @url ||= false
  end
  
  def connection(connection, didReceiveResponse:response)
  end
  
  def connection(connection, didReceiveData:data)
    @data.appendString(NSString.alloc.initWithUTF8String(data))
  end
  
  def connection(connection, didFailWithError:error)
    stop_loading!
  end
  
  def connectionDidFinishLoading(connection)
    @block.call @data
    stop_loading!
  end
  
  def connection(connection, canAuthenticateAgainstProtectionSpace:space)
    @credential ? true : false
  end
  
  def connection(connection, didReceiveAuthenticationChallenge:challenge)
    connection.useCredential(@credential, forAuthenticationChallenge:challenge) if @credential
  end
  
end