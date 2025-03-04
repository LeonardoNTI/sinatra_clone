class Router
  def initialize
    @routes = { get: [], post: [] }
  end

  # Lägg till rutter både för GET och POST
  def add_route(method, path, &action)
    @routes[method] ||= []
    @routes[method] << { path: compile_path(path), action: action }
    puts "Route added for #{method}: #{path}"  # Debugging route addition
  end

  # Matcha rätt rutt baserat på HTTP-metod och väg
  def match_route(request)
    method = request.method.downcase.to_sym
    path = request.resource

    puts "Request found: #{method} #{path}"  # Debugging: Print request method and path

    if @routes[method]
      @routes[method].each do |route|
        puts "Matching #{path} with route regex: #{route[:path][:regex]}"  # Debugging: Print matching regex

        match_data = route[:path][:regex].match(path)
        
        if match_data
          # Extrahera parametrar från vägen om det finns några
          params = extract_params(route[:path][:params], match_data)
          request.params.merge!(params)

          # Utför åtgärden för den matchade vägen
          response = route[:action].call(request)

          # Hantera omdirigering om det finns
          if response.is_a?(Hash) && response[:redirect]
            return Response.new(302, "", { "Location" => response[:redirect] })
          else
            return Response.new(200, response)
          end
        end
      end
    end

    # Returnera 404 om ingen matchning hittades
    Response.new(404, "<h1>404 Not Found</h1>")
  end

  private

  # Kompilera vägen till en regex som kan matcha både statiska och dynamiska vägar
  def compile_path(path)
    if path == '/'
      return { regex: /^\/$/, params: [] }
    end

    params = []
    regex_string = path.split('/').map do |segment|
      if segment.start_with?(':')  # Dynamisk parameter
        params << segment[1..].to_sym  # Lägg till parameternamn
        '([^/]+)'  # Matcha alla tecken för en dynamisk parameter
      else
        segment
      end
    end.join('/')

    { regex: Regexp.new("^#{regex_string}$"), params: params }
  end

  # Extrahera parametrar baserat på vilken ordning de kommer i regex-matchen
  def extract_params(params, match_data)
    params.each_with_index.with_object({}) do |(param, index), hash|
      hash[param] = match_data[index + 1]  # Extrahera parametrar baserat på deras position
    end
  end
end
