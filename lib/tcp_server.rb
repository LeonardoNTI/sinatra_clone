require 'socket'
require 'erb'
require_relative 'request'
require_relative 'router'
require_relative 'response'
require 'fileutils'
require 'uri'

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
    router.add_route(:get, '/about') { erb('about') }
    router.add_route(:get, '/login') { erb('login') }
    router.add_route(:get, '/users/:id') do |request|
      "<h1>User Profile</h1><p>Welcome, user with ID: #{request.params[:id]}</p><a href='/'>Go back to Home</a>"
    end

    router.add_route(:post, '/submit') { { redirect: '/logged_in' } }

    router.add_route(:get, '/add/:num1/:num2') do |request|
      num1 = request.params[:num1].to_i 
      num2 = request.params[:num2].to_i
      result = num1 + num2
      "<h1>Result: #{num1} + #{num2} = #{result}</h1>"
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
    
      # Huvudlogik för att matcha route
      route = router.match_route(request)
    
      # Om vi inte hittar en matchande route
      if route.status == 404
        # Fanns det ingen matchande dynamisk route?
        # Om inte, kolla i public-mappen för att hitta filen
        filename = request.resource.split('/').last
        # Använd File.join för att säkerställa att vi får rätt sökväg utan extra snedstreck
        file_path = File.join('./public', request.resource)
    
        puts "No route found, checking file path: #{file_path}"
    
        if File.exist?(file_path)  # Kollar om filen existerar
          begin
            file_content = File.binread(file_path)  # Läser filen i binärt format
          rescue => e
            return Response.new(500, "<h1>Internal Server Error: #{e.message}</h1>")
          end
    
          # Logga filens storlek
          puts "File content size: #{file_content.bytesize} bytes"
    
          # Bestäm Content-Type baserat på filens extension
          content_type = case File.extname(filename).downcase
                         when '.jpg', '.jpeg' then 'image/jpeg'
                         when '.png' then 'image/png'
                         when '.gif' then 'image/gif'
                         else 'application/octet-stream'
                         end
    
          # Lägg till headers
          headers = {
            "Content-Type" => content_type,
            "Content-Length" => file_content.bytesize.to_s
          }
    
          # Skicka tillbaka filen som svar
          session.print "HTTP/1.1 200 OK\r\n"
          session.print "Content-Type: #{content_type}\r\n"
          session.print "Content-Length: #{file_content.bytesize}\r\n"
          session.print "\r\n"  # Header slut

          session.write(file_content)  # Skicka själva filinnehållet
        else
          # Om filen inte finns
          session.print "HTTP/1.1 404 Not Found\r\n"
          session.print "Content-Type: text/html\r\n"
          session.print "\r\n"
          session.print "<h1>Image Not Found</h1>"
        end
      end
    
      # Skickar tillbaka den matchande ruttens svar
      session.close
    end
  end

  # Simplified ERB rendering method
  def erb(view_file, use_layout = true)
    view_path = "./views/#{view_file}.erb"  # Adjust the path to be relative to the project root
    layout_path = "./views/layout.erb"  # Same for the layout

    # Read view file
    begin
      view_content = File.read(view_path)
    rescue Errno::ENOENT
      return "Error: View file #{view_file} not found."
    end

    # Read layout if enabled
    if use_layout
      begin
        layout_content = File.read(layout_path)
      rescue Errno::ENOENT
        return "Error: Layout file not found."
      end

      # Insert view content into layout
      layout_content.gsub('<%= yield %>', view_content)
    else
      view_content
    end
  end
end

# Start the server
server = HTTPServer.new(4567)
server.start
