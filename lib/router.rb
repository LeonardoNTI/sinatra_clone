# Handles route definitions and request matching for HTTP methods GET and POST.
class Router
  # Initializes a new Router with empty route definitions for GET and POST methods.
  def initialize
    @routes = { get: [], post: [] }
  end

  # Adds a new route for the specified HTTP method and path.
  #
  # @param method [Symbol] HTTP method (:get or :post).
  # @param path [String] Route path (supports dynamic parameters, e.g., '/users/:id').
  # @yield [request] The action to be performed when the route is matched.
  def add_route(method, path, &action)
    @routes[method] ||= []
    @routes[method] << { path: compile_path(path), action: action }
    puts "Route added for #{method}: #{path}"  # Debugging route addition
  end

  # Matches an incoming request to the defined routes and executes the associated action.
  #
  # @param request [Request] The HTTP request object.
  # @return [Response] The HTTP response object (200, 302 for redirects, or 404 if not found).
  def match_route(request)
    method = request.method.downcase.to_sym
    path = request.resource

    puts "Request found: #{method} #{path}"  # Debugging

    if @routes[method]
      @routes[method].each do |route|
        puts "Matching #{path} with route regex: #{route[:path][:regex]}"  # Debugging

        match_data = route[:path][:regex].match(path)
        
        if match_data
          params = extract_params(route[:path][:params], match_data)
          request.params.merge!(params)

          response = route[:action].call(request)

          if response.is_a?(Hash) && response[:redirect]
            return Response.new(302, "", { "Location" => response[:redirect] })
          else
            return Response.new(200, response)
          end
        end
      end
    end

    Response.new(404, "<h1>404 Not Found</h1>")
  end

  private

  # Compiles the given route path into a regular expression for matching requests.
  #
  # Supports dynamic parameters (e.g., '/users/:id').
  #
  # @param path [String] Route path to compile.
  # @return [Hash] Contains the compiled regex and parameter names.
  def compile_path(path)
    if path == '/'
      return { regex: /^\/$/, params: [] }
    end

    params = []
    regex_string = path.split('/').map do |segment|
      if segment.start_with?(':')
        params << segment[1..].to_sym
        '([^/]+)'  # Match any character for dynamic parameter
      else
        segment
      end
    end.join('/')

    { regex: Regexp.new("^#{regex_string}$"), params: params }
  end

  # Extracts dynamic parameters from the request path based on the route definition.
  #
  # @param params [Array<Symbol>] List of parameter names defined in the route.
  # @param match_data [MatchData] Regex match data from the request path.
  # @return [Hash{Symbol => String}] Extracted parameters and their values.
  def extract_params(params, match_data)
    params.each_with_index.with_object({}) do |(param, index), hash|
      hash[param] = match_data[index + 1]
    end
  end
end
