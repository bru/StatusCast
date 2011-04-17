class Status 
 attr_accessor :index, :message, :image
 attr_reader :url
  def initialize(message, index)
    @index = index
    @message = message
    @loading = false
    @data = NSMutableData.new
    if message.user && message.user.avatars
      @url =  NSURL.URLWithString @message.user.avatars.square70 
    else
      NSLog "No user for message #{message.id}"
      @url = nil
    end
    
    @image = NSImage.imageNamed 'NSUser'
  end

  def self.from_socialcast_messages(messages)
    messages.map.with_index { |message, index| new(message, index) } 
  end

  def avatar(cell)
    image
  end

  def text(cell)
    return formatted_message
  end

  def formatted_message
    user_font  = NSFont.fontWithName("Helvetica", size: 11.0)
    user_color = NSColor.purpleColor
    date_font  = NSFont.fontWithName("Helvetica", size: 11.0)
    date_color = NSColor.lightGrayColor
    title_font = NSFont.fontWithName("Helvetica-BoldOblique", size: 11.0)
    user_attributes = { NSFontAttributeName => user_font, NSForegroundColorAttributeName => user_color}
    date_attributes = { NSFontAttributeName => date_font, NSForegroundColorAttributeName => date_color}
    title_attributes = { NSFontAttributeName => title_font }
    
    
    user_string = NSAttributedString.alloc.initWithString(@message.user.name, attributes: user_attributes) if @message.user.name
    date_string = NSAttributedString.alloc.initWithString(" on #{DateTime.parse(@message.created_at).strftime('%d/%m/%Y %H:%M')}\n", attributes: date_attributes) 
    body_string = NSAttributedString.alloc.initWithString(@message.body) if @message.body
    title_string = NSAttributedString.alloc.initWithString("#{@message.title}\n", attributes: title_attributes) if @message.title
    
    message_string = NSMutableAttributedString.alloc.initWithString("")
    message_string.appendAttributedString(user_string)  if user_string
    message_string.appendAttributedString(date_string)  if date_string
    message_string.appendAttributedString(title_string) if title_string
    message_string.appendAttributedString(body_string)  if body_string
    return message_string
  end
  
  def download(&block)
    return if @loading || @url.nil?
    @loading = true
    @block = block

    request = NSURLRequest.requestWithURL @url
    connection = NSURLConnection.alloc.initWithRequest request, delegate:self, startImmediately:true
    if connection
      # NSLog("Status#download (#{@url.relativeString.gsub(/^(.*)\//,'')})")
    else
      NSLog("Status#download FAILED - #{@url.relativeString.gsub(/^(.*)\//,'')} :(")
    end
  end

  def connection(connection, didReceiveResponse:response)
    @data.setLength 0
  end

  def connection(connection, didReceiveData:data)
    @data.appendData data
  end

  def connection(connection, didFailWithError:error)
    @loading = false
  end

  def connectionDidFinishLoading(connection)
    @block.call @data
    @loading = false
  end
  
end
