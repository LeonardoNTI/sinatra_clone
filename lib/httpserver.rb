require 'socket'
require 'erb'
require_relative 'router'
require_relative 'request'
require_relative 'response'
require_relative 'view_renderer'
require_relative 'static_file_handler'

# HTTPServer is responsible for handling incoming HTTP requests,
# serving static files, and routing dynamic requests using a router instance.
#
# It listens on a specified port, processes incoming connections,
# serves static content when available, and delegates dynamic requests to the router.
class HTTPServer
  include StaticFileHandler

  # Initializes the HTTP server with a given port and router.
  #
  # @param port [Integer] the port number the server listens on
  # @param router [Router] the router instance for handling routes
  def initialize(port, router)
    @port = port
    @router = router
  end

  # Starts the HTTP server, accepts incoming connections, and handles requests.
  #
  # This method listens for incoming TCP connections, processes HTTP requests,
  # serves static files if they exist, and routes requests using the provided router.
  #
  # @return [void]
  def start
    server = TCPServer.new(@port)
    puts "Listening on #{@port}"

    while session = server.accept
      data = ""
      while line = session.gets and line !~ /^\s*$/  # Read request headers
        data += line
      end

      request = Request.new(data)
      file_path = "./public#{request.resource}"

      if File.exist?(file_path) && !File.directory?(file_path)
        handle_static_files(request, session)
      else
        route = @router.match_route(request)

        if route
          session.print route.to_s
          log_request("ROUTE MATCHED", request.resource)
        else
          session.print "HTTP/1.1 404 Not Found\r\n"
          session.print "Content-Type: text/html\r\n\r\n"
          session.print "<h1>404 Not Found</h1>"
        end
      end

      session.close
    end
  end

  private

  # Logs the details of an HTTP request for debugging purposes.
  #
  # @param action [String] the action performed (e.g., 'ROUTE MATCHED')
  # @param route [String] the requested route
  # @param additional_info [String] optional additional information
  # @return [void]
  def log_request(action, route, additional_info = "")
    puts "-----------------------"
    puts "ACTION: #{action.upcase}"
    puts "ROUTE: #{route}"
    puts "INFO: #{additional_info}" unless additional_info.empty?
    puts "-----------------------"
  end
end
