class Router
  def initialize
    @routes = {}
  end

  def add_route(method, path, &action)
    @routes[method] ||= {}
    @routes[method][normalize_path(path)] = action
  end

  def match_route(request)
    method = request.method.to_sym
    path = normalize_path(request.resource)

    puts "Matching route for method=#{method}, path=#{path}"

    route = @routes[method] && @routes[method][path]

    if route
      # If the route returns a hash with :redirect, handle the redirect
      response = route.call
      if response.is_a?(Hash) && response[:redirect]
        # Perform a 302 redirect to the location specified in the :redirect key
        return Response.new(302, "", { "Location" => response[:redirect] })
      else
        # Return the normal response
        return Response.new(200, response)
      end
    else
      # Return 404 if no route is found
      return Response.new(404, "<h1>404 Not Found</h1>")
    end
  end

  private

  def normalize_path(path)
    path.split('?').first
  end
end
