require_relative 'request'

class Router
  def initialize
    @routes = {}
  end

  # Add a route with a specific HTTP method and path
  def add_route(method, path, &action)
    method = method.upcase
    @routes[method] ||= {}
    @routes[method][path] = action
  end

  # Match a request and execute the appropriate route
  def match_route(request)
    method = request.method
    path = request.resource

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
