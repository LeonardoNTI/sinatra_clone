require_relative 'response'

class Router
  def initialize
    @routes = {}
  end

  # Add a route with a specific HTTP method and path
  def add_route(method, path, &action)
    @routes[method] ||= {}
    @routes[method][normalize_path(path)] = action
  end

  # Match a request and execute the appropriate route
  def match_route(request)
    method = request.method.to_sym
    path = normalize_path(request.resource)

    puts "Matching route for method=#{method}, path=#{path}"

    # Look for the route in the routes hash
    route = @routes[method] && @routes[method][path]

    if route
      # If found, call the route and return the response
      response_body = route.call
      Response.new(200, response_body)
    else
      # Return 404 if no route is found
      Response.new(404, "<h1>404 Not Found</h1>")
    end
  end

  private

  # Normalize the path by removing query parameters
  def normalize_path(path)
    # Remove query parameters (anything after a '?' symbol)
    path.split('?').first
  end
end
