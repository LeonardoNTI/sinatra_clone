require 'socket'
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
        router.add_route(:get, '/') { "<h2>Wooow</h2>" }
        router.add_route(:get, '/banan') { "<h2>Hello</h2>" }
        router.add_route(:get, '/about') { "<h2>About This Server</h2>" }
        router.add_route(:get, '/login') do
            "<h1>Login Form</h1>
            <form action='/submit' method='POST'>
              <label for='username'>Username:</label>
              <input type='text' id='username' name='username' required><br><br>
              
              <label for='password'>Password:</label>
              <input type='password' id='password' name='password' required><br><br>
              
              <button type='submit'>Login</button>
            </form>"
          end
          
        router.add_route(:post, '/login') { "<h2>Form Submitted</h2>" } 




        while session = server.accept 
            data = ""
            while line = session.gets and line !~ /^\s*$/
                data += line
            end
            puts "RECEIVED REQUEST"
            puts "-" * 40
            puts data
            puts "-" * 40 

            request = Request.new(data)
            
            response = router.match_route(request)

            session.print response.to_s
            session.close

        end
    end
end

server = HTTPServer.new(4567)
server.start