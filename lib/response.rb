class Response
  attr_reader :status, :body, :headers

  def initialize(status, body, headers = { "Content-Type" => "text/html" })
    @status = status
    @body = body
    @headers = headers
  end

  def to_s
    # Convert the response into the appropriate HTTP format
    response = "HTTP/1.1 #{@status} #{status_message}\r\n"
    @headers.each do |key, value|
      response += "#{key}: #{value}\r\n"
    end
    response += "\r\n#{@body}"
    response
  end

  private

  def status_message
    case @status
    when 200 then "OK"
    when 302 then "Found" # 302 is for redirect
    when 404 then "Not Found"
    else "Unknown Status"
    end
  end
end