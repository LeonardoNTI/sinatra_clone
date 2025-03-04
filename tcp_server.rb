require 'socket'
require 'erb'
require_relative 'lib/app'  # Ladda appen

server = HTTPServer.new(4567)
server.start
