# Represents an HTTP response, including status, headers, and body content.
class Response
  # @return [Integer] HTTP status code (e.g., 200, 302, 404).
  attr_reader :status
  
  # @return [String] Body content of the response.
  attr_reader :body
  
  # @return [Hash] HTTP headers (default is "Content-Type" => "text/html").
  attr_reader :headers

  # Initializes a new Response object.
  #
  # @param status [Integer] HTTP status code.
  # @param body [String] Response body content.
  # @param headers [Hash] HTTP headers (default is "Content-Type" => "text/html").
  def initialize(status, body, headers = { "Content-Type" => "text/html" })
    @status = status
    @body = body
    @headers = headers
  end

  # Converts the Response object into an HTTP response string format.
  #
  # @return [String] The full HTTP response string.
  def to_s
    response = "HTTP/1.1 #{@status} #{status_message}\r\n"
    
    @headers.each do |key, value|
      response += "#{key}: #{value}\r\n"
    end
    
    response += "\r\n#{@body}"
    response
  end

  private

  # Maps HTTP status codes to their respective messages.
  #
  # @return [String] Status message corresponding to the status code.
  def status_message
    case @status
    when 200 then "OK"
    when 302 then "Found" # For HTTP redirects
    when 404 then "Not Found"
    else "Unknown Status"
    end
  end
end
