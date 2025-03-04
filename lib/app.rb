require 'socket'  
require 'erb'
require_relative 'router'
require_relative 'request'
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
  
    router = Router.new
  
    # Dynamiska rutter
    router.add_route(:get, '/') { erb('index') }
    router.add_route(:get, '/logged_in') { erb('logged_in') }
    router.add_route(:get, '/about') { erb('about') }
    router.add_route(:get, '/login') { erb('login') }
    
    router.add_route(:get, '/add/:num1/:num2') do |request|
      num1 = request.params[:num1].to_i
      num2 = request.params[:num2].to_i
      result = num1 + num2
      "<h1>Result: #{num1} + #{num2} = #{result}</h1><a href='/'>Go back to Home</a>"
    end
  
    router.add_route(:get, '/users/:id') do |request|
      user_id = request.params[:id]
      next_id = user_id.to_i + 1  # Beräkna nästa ID
      "<h1>User: #{user_id}</h1>
      <a href='/users/#{next_id}'>Next User (+1)</a>
      <a href='/'>Go back to Home</a>"
    end
    
  
    router.add_route(:post, '/submit') do |request|
      "<h1>Post request received! <a href='/'>Go back to Home</a></h1>"
    end
  
    # Main server loop
    while session = server.accept
      data = ""
      while line = session.gets and line !~ /^\s*$/  # Läs request headers
        data += line
      end
  
      request = Request.new(data)
  
      # Kolla om det är en statisk fil
      if request.resource.start_with?('/img/')
        handle_static_files(request, session)  # Hantera statiska filer
      else
        # Matcha dynamiska rutter
        route = router.match_route(request)
  
        if route
          session.print route.to_s  # Skicka svar till klienten
          log_request("ROUTE MATCHED", request.resource, "")
        else
          session.print "HTTP/1.1 404 Not Found\r\n"
          session.print "Content-Type: text/html\r\n"
          session.print "\r\n"
          session.print "<h1>404 Not Found</h1>"
        end
      end
  
      session.close
    end
  end
  

  def erb(view_file, use_layout = true)
    view_path = "./views/#{view_file}.erb"
    layout_path = "./views/layout.erb"

    begin
      view_content = File.read(view_path)
    rescue Errno::ENOENT
      return Response.new(404, "<h1>Error: View file #{view_file} not found.</h1>")
    end

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

  private

  def handle_static_files(request, session)
    filename = request.resource.split('/').last
    file_path = "./public#{request.resource}"

    if File.exist?(file_path)
      file_content = File.binread(file_path)
      content_type = get_content_type(filename)
      content_length = file_content.bytesize

      session.print "HTTP/1.1 200 OK\r\n"
      session.print "Content-Type: #{content_type}\r\n"
      session.print "Content-Length: #{content_length}\r\n"
      session.print "\r\n"
      session.print file_content
    else
      session.print "HTTP/1.1 404 Not Found\r\n"
      session.print "Content-Type: text/html\r\n"
      session.print "\r\n"
      session.print "<h1>File Not Found</h1>"
    end
  end

  def log_request(action, route, additional_info)
    # Printing the separator line
    puts "-----------------------"
    # Logging the action, route, and additional info in all caps for clarity
    puts "ACTION: #{action.upcase}"
    puts "ROUTE: #{route}"
    unless additional_info.empty?
      puts "INFO: #{additional_info}"
    end
    puts "-----------------------"
  end

  def get_content_type(filename)
    case File.extname(filename).downcase
    when '.jpg', '.jpeg' then 'image/jpeg'
    when '.png' then 'image/png'
    when '.gif' then 'image/gif'
    when '.svg' then 'image/svg+xml'
    when '.ico' then 'image/x-icon'
    when '.html' then 'text/html'
    when '.css' then 'text/css'
    when '.js' then 'application/javascript'
    else 'application/octet-stream'
    end
  end
end
