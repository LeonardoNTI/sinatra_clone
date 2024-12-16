require 'socket'
require_relative 'request'
require_relative 'router'

class HTTPServer

    def initialize(port)
        @port = port
    end

    def start
        server = TCPServer.new(@port)
        puts "Listening on #{@port}"
      
        # Initialize Router and Add Routes
        router = Router.new
        router.add_route('GET', '/') { [200, "<h2>Wooow</h2>"] }
        router.add_route('GET', '/banan') { [200, "<h2>Helo</h2>"] }
        router.add_route('GET', '/about') { [200, "<h2>About This Server</h2>"] }
        router.add_route('POST', '/submit') { [200, "<h2>Form Submitted</h2>"] }

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
            
            status, html = router.match_route(request)

            session.print "HTTP/1.1 #{status}\r\n"
            session.print "Content-Type: text/html\r\n"
            session.print "\r\n"
            session.print html
            session.close
        end
    end
end

server = HTTPServer.new(4567)
server.start