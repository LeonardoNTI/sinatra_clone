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

    router.add_route(:get, '/img/:url') do |request|
      url = URI.decode_www_form_component(request.params[:url])
      "<img src='#{url}'>"
    end
    
    


    # Serve static files (images, CSS, JS) from public directory
    router.add_route(:get, '/img/:filename') do |request|
      filename = request.params[:filename]
      file_path = "./public/img/#{filename}"

      # Check if the file exists
      if File.exist?(file_path)
        # Read the file as binary (for images)
        begin
          file_content = File.binread(file_path)
        rescue => e
          return Response.new(500, "<h1>Internal Server Error: #{e.message}</h1>")
        end

        # Determine content type based on the file extension
        content_type = case File.extname(filename).downcase
                       when '.jpg', '.jpeg' then 'image/jpeg'
                       when '.png' then 'image/png'
                       when '.gif' then 'image/gif'
                       else 'application/octet-stream'  # Default for unknown file types
                       end

        # Return image with appropriate Content-Type
        return Response.new(200, file_content, { "Content-Type" => content_type })
      else
        return Response.new(404, "<h1>Image Not Found</h1>")
      end
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
