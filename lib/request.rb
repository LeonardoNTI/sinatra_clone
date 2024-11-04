# request.rb
class Request
  attr_reader :method, :resource, :version, :headers, :params

  def initialize(request_string)
    # Dela upp hela request-strängen
    lines = request_string.split("\n")

    # Initiera headers som en tom hash
    @headers = {}

    # Gå igenom raderna och hantera första raden separat
    body_started = false
    body_content = ""

    lines.each do |line|
      if line == lines[0]  # Hantera första raden
        @method, @resource, @version = line.split(" ")
        @method = @method.downcase.to_sym  # Första -> metoden (GET, POST)
      elsif line.empty?  # Tom rad markerar slutet av headers och början av body
        body_started = true
      elsif body_started
        # Efter tom rad börjar vi samla in body-innehåll (POST-data)
        body_content << line
      else  # Hantera headers
        header_parts = line.split(": ")
        if header_parts.size == 2
          @headers[header_parts[0]] = header_parts[1]
        end
      end
    end

    # Initiera params som en tom hash
    @params = {}

    # Hantera query-parametrar för GET
    if @method == :get && @resource.include?('?')
      resource_parts = @resource.split('?')
      @resource = resource_parts[0]  # Uppdatera resursen utan query-strängen
      query_string = resource_parts[1] # Ta query-strängen

      # Dela upp query-strängen i individuella parametrar
      params_array = query_string.split('&')
      params_array.each do |param|
        key_value = param.split('=')
        key = key_value[0]
        value = key_value[1]
        @params[key] = value if key && value
      end
    end

    # Hantera body-parametrar för POST
    if @method == :post && !body_content.empty?
      # Om det finns innehåll i kroppen, dela upp det på samma sätt som GET-parametrar
      body_params = body_content.split('&')
      body_params.each do |param|
        key_value = param.split('=')
        key = key_value[0]
        value = key_value[1]
        @params[key] = value if key && value
      end
    end
  end
end

