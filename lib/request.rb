class Request
  attr_reader :method, :resource, :version, :headers, :params

  def initialize(request_string)
    lines = request_string.split("\n")
    @headers = {}
    @params = {}

    puts "Raw request string: #{request_string}"  # Debugging line
    parse_first_line(lines[0])
    body_content = parse_lines(lines[1..])
    parse_params(body_content)
  end

  private

  def parse_first_line(line)
    # Check if line is nil or empty
    raise 'Invalid Request: First line is missing' if line.nil? || line.empty?

    @method, @resource, @version = line.split(' ')
    @method = @method.downcase.to_sym
    validate_request_components
  end

  def validate_request_components
    validate_method
    validate_resource
    validate_version
  end

  def validate_method
    raise 'Invalid HTTP Method' unless %i[get post].include?(@method)
  end

  def validate_resource
    raise 'Invalid Resource' if @resource.nil? || @resource.empty?
  end

  def validate_version
    raise 'Invalid HTTP Version' unless @version.match?(%r{^HTTP/\d\.\d$})
  end

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

  def parse_header_line(line)
    key, value = line.split(': ', 2)
    add_header(key, value)
  end

  def add_header(key, value)
    @headers[key] = value if key && value
  end

  def parse_params(body_content)
    parse_query_params if @method == :get
    parse_body_params(body_content) if @method == :post
  end

  def parse_query_params
    return unless @resource.include?('?')

    @resource, query_string = @resource.split('?')
    parse_param_string(query_string)
  end

  def parse_body_params(body_content)
    return if body_content.empty?

    parse_param_string(body_content)
  end

  def parse_param_string(param_string)
    param_string.split('&').each { |param| parse_param(param) }
  end

  def parse_param(param)
    key, value = param.split('=', 2)
    @params[key] = value if key && value
  end
end
