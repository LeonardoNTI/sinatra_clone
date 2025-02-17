class Router
  def initialize
    @routes = {}
  end

  def add_route(method, path, &action)
    @routes[method] ||= []
    @routes[method] << { path: compile_path(path), action: action }
    puts "Route added for #{method}: #{path}"  # Debugging route addition
  end

  def match_route(request)
    method = request.method
    path = request.resource

    puts "Matching route for method=#{method}, path=#{path}"  # Debugging

    if @routes[method]
      @routes[method].each do |route|
        match_data = route[:path][:regex].match(path)
        puts "match_data: #{match_data.inspect}"  # Debugging match data

        if match_data
          params = extract_params(route[:path][:params], match_data)
          puts "Extracted params: #{params.inspect}"  # Debugging params
          request.params.merge!(params)
          response = route[:action].call(request)

          # Handle redirect if any
          if response.is_a?(Hash) && response[:redirect]
            return Response.new(302, "", { "Location" => response[:redirect] })
          else
            return Response.new(200, response)
          end
        end
      end
    end

    # Return 404 if no match is found
    Response.new(404, "<h1>404 Not Found</h1>")
  end

  private

  def compile_path(path)
    if path == '/'
      return { regex: /^\/$/, params: [] }
    end

    params = []
    regex_string = path.split('/').map do |segment|
      if segment.start_with?(':')
        params << segment[1..].to_sym
        '([^/]+)'  # Match dynamic parameters
      else
        segment
      end
    end.join('/')

    { regex: Regexp.new("^#{regex_string}$"), params: params }
  end

  def extract_params(params, match_data)
    params.each_with_index.with_object({}) do |(param, index), hash|
      hash[param] = match_data[index + 1]
    end
  end
end
