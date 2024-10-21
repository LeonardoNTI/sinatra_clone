# request.rb
class Request
  attr_reader :method, :resource, :version, :headers, :params

  def initialize(request_string)
    # Dela upp hela request-strängen i rader
    lines = request_string.split("\n")

    # Dela upp första raden för att få metod, resurs och version
    request_line = lines[0].split(" ")
    @method = request_line[0]        # Första delen är metoden (GET, POST)
    @resource = request_line[1]      # Andra delen är resursen (ex: /examples)
    @version = request_line[2]       # Tredje delen är versionen (HTTP/1.1)

    # Initiera headers som en tom hash
    @headers = {}
    
    # Hämta headers 
    @headers['Host'] = lines[1].split(": ")[1] if lines[1]
    @headers['User-Agent'] = lines[2].split(": ")[1] if lines[2]
    @headers['Accept-Encoding'] = lines[3].split(": ")[1] if lines[3]
    @headers['Accept'] = lines[4].split(": ")[1] if lines[4]

    # Initiera params som en tom hash
    @params = {}

    # Hantera query-parametrar för GET
    if @method == 'GET' && @resource.include?('?')
      resource_parts = @resource.split('?')
      @resource = resource_parts[0]  # Uppdatera resursen utan query-strängen
      query_string = resource_parts[1] # Ta query-strängen

      # Dela upp query-strängen i individuella parametrar
      params_array = query_string.split('&')
      key_value = params_array[0].split('=') # Första param
      key = key_value[0]
      value = key_value[1]
      @params[key] = value if key && value
    end
  end
end

# Testa klassen med get-examples.request.txt
request_string = File.read('spec/example_requests/get-examples.request.txt')
request = Request.new(request_string)

# Utskrift av resultat
puts "Method: #{request.method}"       # Förväntat: GET
puts "Resource: #{request.resource}"   # Förväntat: /examples
puts "Version: #{request.version}"     # Förväntat: HTTP/1.1
puts "Headers: #{request.headers}"     # Förväntat: Headers som definierats
puts "Params: #{request.params}"       # Förväntat: {}
