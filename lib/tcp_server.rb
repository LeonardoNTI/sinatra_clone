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

    router.add_route(:post, '/submit') do |request|
      "<h1>Form submitted successfully!</h1><a href='/'>Back to home</a>"
    end

    router.add_route(:get, '/add/:num1/:num2') do |request|
      num1 = request.params[:num1].to_i
      num2 = request.params[:num2].to_i
      result = num1 + num2
      "<h1>Result: #{num1} + #{num2} = #{result}</h1><a href='/'>Go back to Home</a>" 
    end

    # Main server loop
    while session = server.accept
      data = ""
      while line = session.gets and line !~ /^\s*$/  # Read request headers
        data += line
      end

      # Felsökning: Skriv ut den mottagna förfrågan
      puts "RECEIVED REQUEST"
      puts "-" * 40
      puts data
      puts "-" * 40

      request = Request.new(data)

      # Felsökning: Skriv ut resursen som efterfrågas
      puts "Request resource: #{request.resource}"

      # Match route from router (dynamic routes)
      route = router.match_route(request)

      if route
        puts "Route matched successfully!"  # Felsökning: Skriv ut att en matchad rutt hittades
        session.print route.to_s  # Send the response to the client
      else
        # Felsökning: Skriv ut att ingen rutt matchades
        puts "No route matched for resource: #{request.resource}"

        # Kontrollera om filen finns i 'public' (image handling)
        filename = request.resource.split('/').last
        file_path = "./public#{request.resource}"

        # Felsökning: Visa exakt filväg som servern söker
        puts "Looking for file at path: #{file_path}"

        if File.exist?(file_path)
          file_content = File.binread(file_path)
          content_type = case File.extname(filename).downcase
                         when '.jpg', '.jpeg' then 'image/jpeg'
                         when '.png' then 'image/png'
                         when '.gif' then 'image/gif'
                         else 'application/octet-stream'
                         end
          
          content_length = file_content.bytesize  # Beräkna korrekt filstorlek i bytes

          # Felsökning: Skriv ut file content length
          puts "File size: #{content_length} bytes"

          # Skicka svar med korrekta HTTP-huvuden för statiska filer
          session.print "HTTP/1.1 200 OK\r\n"
          session.print "Content-Type: #{content_type}\r\n"
          session.print "Content-Length: #{content_length}\r\n"  # Korrekt content-length
          session.print "\r\n"  # End of headers
          session.print file_content  # Skicka filinnehållet till klienten
        else
          # Felsökning: Filen hittades inte
          puts "File not found: #{file_path}"

          session.print "HTTP/1.1 404 Not Found\r\n"
          session.print "Content-Type: text/html\r\n"
          session.print "\r\n"
          session.print "<h1>Image Not Found</h1>"
        end
      end

      session.close
    end
  end

  # ERB rendering method with layout handling
  def erb(view_file, use_layout = true)
    view_path = "./views/#{view_file}.erb"
    layout_path = "./views/layout.erb"

    # Läs view-filen
    begin
      view_content = File.read(view_path)
    rescue Errno::ENOENT
      return Response.new(404, "<h1>Error: View file #{view_file} not found.</h1>")
    end

    # Läs layout om det är aktiverat
    if use_layout
      begin
        layout_content = File.read(layout_path)
      rescue Errno::ENOENT
        return Response.new(500, "<h1>Error: Layout file not found.</h1>")
      end

      final_content = layout_content.gsub('<%= yield %>', view_content)
    else
      final_content = view_content
    end

    Response.new(200, final_content, { "Content-Type" => "text/html" })
  end
end

# Start the server
server = HTTPServer.new(4567)
server.start
