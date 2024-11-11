# request.rb
class Request
  attr_reader :method, :resource, :version, :headers, :params

  def initialize(request_string)
    lines = request_string.split("\n")
    @headers = {}
    @params = {}

    parse_first_line(lines[0])
    body_content = parse_lines(lines[1..])
    parse_query_params if @method == :get
    parse_body_params(body_content) if @method == :post
  end

  private

  # Hanterar första raden
  def parse_first_line(line)
    @method, @resource, @version = line.split(' ')
    @method = @method.downcase.to_sym
  end

  # Hanterar headers och extraherar body-innehåll
  def parse_lines(lines)
    body_started = false
    body_content = ''

    lines.each { |line| body_started = process_line(line, body_started, body_content) }

    body_content
  end

  # Ny metod som hanterar varje rad
  def process_line(line, body_started, body_content)
    if line.empty?
      true
    elsif body_started
      append_body_content(body_content, line)
      true
    else
      parse_header_line(line)
      false
    end
  end

  # Ny metod för att hantera en header-rad
  def parse_header_line(line)
    key, value = line.split(': ', 2)
    @headers[key] = value if key && value
  end

  # Ny metod för att lägga till body-innehåll
  def append_body_content(body_content, line)
    body_content << line
  end

  # Hanterar query-parametrar för GET-förfrågningar
  def parse_query_params
    return unless @resource.include?('?')

    @resource, query_string = @resource.split('?')
    query_string.split('&').each do |param|
      key, value = param.split('=', 2)
      @params[key] = value if key && value
    end
  end

  # Hanterar body-parametrar för POST-förfrågningar
  def parse_body_params(body_content)
    return if body_content.empty?

    body_content.split('&').each do |param|
      key, value = param.split('=', 2)
      @params[key] = value if key && value
    end
  end
end
