# Represents an HTTP request, parsing its method, resource, version, headers, and parameters.
class Request
  # @return [Symbol] HTTP method (`:get` or `:post`)
  attr_reader :method
  
  # @return [String] Requested resource path
  attr_reader :resource
  
  # @return [String] HTTP version (e.g., "HTTP/1.1")
  attr_reader :version
  
  # @return [Hash] HTTP headers
  attr_reader :headers
  
  # @return [Hash] Query or body parameters
  attr_reader :params

  # Initializes a new Request object by parsing the HTTP request string.
  #
  # @param request_string [String] Raw HTTP request string.
  def initialize(request_string)
    lines = request_string.split("\n")
    @headers = {}
    @params = {}

    puts "Raw request string: #{request_string}"  # Debugging code
    parse_first_line(lines[0])
    body_content = parse_lines(lines[1..])
    parse_params(body_content)
  end

  private

  # Parses the first line of the HTTP request (method, resource, version).
  #
  # @param line [String] The first line of the HTTP request.
  # @raise [RuntimeError] If the first line is missing or invalid.
  def parse_first_line(line)
    raise 'Invalid Request: First line is missing' if line.nil? || line.empty?

    @method, @resource, @version = line.split(' ')
    @method = @method.downcase.to_sym
    validate_request_components
  end

  # Validates the HTTP method, resource, and version.
  #
  # @raise [RuntimeError] If any component is invalid.
  def validate_request_components
    validate_method
    validate_resource
    validate_version
  end

  # Validates HTTP method (`:get` or `:post`).
  #
  # @raise [RuntimeError] If the method is invalid.
  def validate_method
    raise 'Invalid HTTP Method' unless %i[get post].include?(@method)
  end

  # Validates resource presence.
  #
  # @raise [RuntimeError] If the resource is nil or empty.
  def validate_resource
    raise 'Invalid Resource' if @resource.nil? || @resource.empty?
  end

  # Validates HTTP version format.
  #
  # @raise [RuntimeError] If version format is invalid.
  def validate_version
    raise 'Invalid HTTP Version' unless @version.match?(%r{^HTTP/\d\.\d$})
  end

  # Parses headers and body content from the request lines.
  #
  # @param lines [Array<String>] Lines of the HTTP request excluding the first line.
  # @return [String] Body content of the request.
  def parse_lines(lines)
    body_started = false
    body_content = ''
    
    lines.each do |line|
      if line.empty?
        body_started = true
      elsif body_started
        body_content << line
      else
        parse_header_line(line)
      end
    end
    
    body_content
  end

  # Parses a header line into key and value.
  #
  # @param line [String] Header line in "Key: Value" format.
  def parse_header_line(line)
    key, value = line.split(': ', 2)
    add_header(key, value)
  end

  # Adds a header to the headers hash.
  #
  # @param key [String] Header key.
  # @param value [String] Header value.
  def add_header(key, value)
    @headers[key] = value if key && value
  end

  # Parses query or body parameters based on HTTP method.
  #
  # @param body_content [String] Body content for POST requests.
  def parse_params(body_content)
    parse_query_params if @method == :get
    parse_body_params(body_content) if @method == :post
  end

  # Parses query parameters for GET requests.
  def parse_query_params
    return unless @resource.include?('?')

    @resource, query_string = @resource.split('?')
    parse_param_string(query_string)
  end

  # Parses body parameters for POST requests.
  #
  # @param body_content [String] Body content to parse.
  def parse_body_params(body_content)
    return if body_content.empty?
    
    parse_param_string(body_content)
  end

  # Parses a parameter string (query or body) into key-value pairs.
  #
  # @param param_string [String] Parameter string in "key1=value1&key2=value2" format.
  def parse_param_string(param_string)
    param_string.split('&').each { |param| parse_param(param) }
  end

  # Parses a single parameter into key and value.
  #
  # @param param [String] Single parameter in "key=value" format.
  def parse_param(param)
    key, value = param.split('=', 2)
    @params[key] = value if key && value
  end
end
