# Module to handle serving static files for HTTP requests.
module StaticFileHandler
  # Handles serving static files from the `./public` directory based on the request path.
  #
  # If the requested file exists, it returns the file content with the appropriate headers.
  # Otherwise, it responds with a 404 Not Found error.
  #
  # @param request [Request] The HTTP request object.
  # @param session [TCPSocket] The client session for sending the HTTP response.
  def handle_static_files(request, session)
    file_path = "./public#{request.resource}"

    if File.exist?(file_path) && !File.directory?(file_path)
      file_content = File.binread(file_path)
      content_type = get_content_type(file_path)
      content_length = file_content.bytesize

      session.print "HTTP/1.1 200 OK\r\n"
      session.print "Content-Type: #{content_type}\r\n"
      session.print "Content-Length: #{content_length}\r\n"
      session.print "\r\n"
      session.print file_content
    else
      session.print "HTTP/1.1 404 Not Found\r\n"
      session.print "Content-Type: text/html\r\n\r\n"
      session.print "<h1>404 File Not Found</h1>"
    end
  end

  private

  # Determines the content type based on the file extension.
  #
  # Supports common types such as HTML, CSS, JavaScript, images, and icons.
  # Defaults to 'application/octet-stream' for unknown types.
  #
  # @param file_path [String] The path of the file to determine the content type for.
  # @return [String] The MIME type corresponding to the file extension.
  def get_content_type(file_path)
    case File.extname(file_path).downcase
    when '.html' then 'text/html'
    when '.css' then 'text/css'
    when '.js' then 'application/javascript'
    when '.png' then 'image/png'
    when '.jpg', '.jpeg' then 'image/jpeg'
    when '.gif' then 'image/gif'
    when '.svg' then 'image/svg+xml'
    when '.ico' then 'image/x-icon'
    else 'application/octet-stream'
    end
  end
end
