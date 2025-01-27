require 'socket'
require 'erb'
require_relative 'request'
require_relative 'router'
require_relative 'response'

class HTTPServer
  def initialize(port)
    @port = port
  end

  def start
    server = TCPServer.new(@port)
    puts "Listening on #{@port}"

    # Initialize Router and Add Routes
    router = Router.new
    router.add_route(:get, '/') { erb('index') }
    router.add_route(:get, '/logged_in') { erb('logged_in') }
    router.add_route(:get, '/about') { "<h2>About This Server</h2>" }
    router.add_route(:get, '/login') { erb('login') }
    router.add_route(:get, '/users/:id') do |request|
      "<h1>User Profile</h1><p>Welcome, user with ID: #{request.params[:id]}</p>"
    end
    
    

    router.add_route(:post, '/submit') { { redirect: '/logged_in' } }

    while session = server.accept
      data = ""
      while line = session.gets and line !~ /^\s*$/  # Read request headers
        data += line
      end
      puts "RECEIVED REQUEST"
      puts "-" * 40
      puts data
      puts "-" * 40

      request = Request.new(data)

      route = router.match_route(request)

      session.print route.to_s  # Send the response to the client
      session.close
    end
  end

  # Simplified erb method
  def erb(html_file)
    file = File.open("../views/#{html_file}.erb")  # Open the ERB file
    ERB.new(file.read).result(binding)  # Render it and return the result
  end
end

server = HTTPServer.new(4567)
server.start
