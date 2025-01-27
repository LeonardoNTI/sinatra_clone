class Router
  def initialize
    @routes = {}
  end

  def add_route(method, path, &action)
    @routes[method] ||= []
    @routes[method] << { path: compile_path(path), action: action }
    puts "Route added for #{method}: #{path}"  # Kontrollväg för rutterna
  end

  def match_route(request)
    method = request.method
    path = request.resource

    puts "Matching route for method=#{method}, path=#{path}"  # Kontrollväg för matchningar

    if @routes[method]
      @routes[method].each do |route|
        match_data = route[:path][:regex].match(path)
        puts "match_data: #{match_data.inspect}"  # Debugging: kontrollera match_data

        if match_data
          params = extract_params(route[:path][:params], match_data)
          puts "Extracted params: #{params.inspect}"  # Debugging: kontrollera de extraherade parametrarna
          request.params.merge!(params)
          response = route[:action].call(request)

          # Om det är en redirect
          if response.is_a?(Hash) && response[:redirect]
            return Response.new(302, "", { "Location" => response[:redirect] })
          else
            return Response.new(200, response)
          end
        end
      end
    end

    # Returnera 404 om ingen match hittades
    Response.new(404, "<h1>404 Not Found</h1>")
  end

  private

  def compile_path(path)
    # Hantera tom sökväg ("/")
    if path == '/'
      return { regex: /^\/$/, params: [] }
    end

    params = []
    regex_string = path.split('/').map do |segment|
      if segment.start_with?(':')
        params << segment[1..].to_sym
        '([^/]+)'  # Matcha varje parameter
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
