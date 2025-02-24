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
      # Använd find istället för each för att hitta den första matchande rutt
      route = @routes[method].find do |route|
        match_data = route[:path][:regex].match(path)
        if match_data
          params = extract_params(route[:path][:params], match_data)
          request.params.merge!(params)
          true  # Om matchning hittades, returnera true för att stoppa vidare sökning
        end
      end

      # Om vi hittar en matchad route
      if route
        response = route[:action].call(request)

        # Om det är en redirect (302)
        if response.is_a?(Hash) && response[:redirect]
          return Response.new(302, "", { "Location" => response[:redirect] })
        else
          # Logga full respons och ge tillbaka korrekt 200 OK
          puts "Full response: #{response.to_s}"
          return Response.new(200, response.body, response.headers)
        end
      end
    end

    # Returnera 404 om ingen matchning hittades
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
