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
    router.add_route(:get, '/about') { erb('about')}
    router.add_route(:get, '/login') { erb('login') }
    router.add_route(:get, '/users/:id') do |request|
      # Här genererar vi själva HTML-innehållet
      "<h1>User Profile</h1><p>Welcome, user with ID: #{request.params[:id]}</p><a href='/'>Go back to Home</a>"
    end

    router.add_route(:post, '/submit') { { redirect: '/logged_in' } }

    router.add_route(:get, '/add/:num1/:num2') do |request|
      num1 = request.params[:num1].to_i 
      num2 = request.params[:num2].to_i
      result = num1 + num2
      "<h1>Resultat: #{num1} + #{num2} = #{result}</h1>"
    end

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

  # Förenklad erb-metod som läser in vyfil och layout
  def erb(view_file, use_layout = true)
    view_path = "../views/#{view_file}.erb"
    layout_path = "../views/layout.erb"

    # Läs in vyfilen
    begin
      view_content = File.read(view_path)
    rescue Errno::ENOENT => e
      return "Error: View file #{view_file} not found."
    end

    # Om layout är påslagen, läs in layoutfilen
    if use_layout
      begin
        layout_content = File.read(layout_path)
      rescue Errno::ENOENT => e
        return "Error: Layout file not found."
      end

      # Sätt in vyinnehållet i layoutens yield-område
      layout_content.gsub('<%= yield %>', view_content)
    else
      view_content
    end
  end
end

# Skapa och starta servern
server = HTTPServer.new(4567)
server.start
