require_relative 'request'
require 'debug'

class Router
  def initialize
    @routes = []
  end

  # Add a route with a specific HTTP method and path
  def add_route(method, path, &action)
    @routes << {method: method, path: path, block: action}
  end

  # Match a request and execute the appropriate route
  def match_route(request)
    binding.break
    method = request.method.to_sym
    path = request.resource
    #debug
    puts "Matching route for method=#{method}, path=#{path}"

    if @routes[method] && @routes[method][path]
      @routes[method][path].call
    else
      default_response
    end
  end

  private

  # Default response for unmatched routes
  def default_response
    [404, "<h1>404 Not Found</h1>"]
  end
end

router = Router.new


router.add_route(:get, '/examples') {'<h1> HEJ </h1>'}
router.add_route(:post, '/banan') {'<h1> NY BANAN </h1>'}

router.match_route(Request.new(File.read('spec\example_requests\get-examples.request.txt')))