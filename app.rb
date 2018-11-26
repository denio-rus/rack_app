require_relative 'time_formatter'

class App
  def call(env)
    @request = Rack::Request.new(env)

    return not_found_response unless unknown_route?
    return no_formats_given_response unless format_given?

    formatted_time_response
  end

  private

  def not_found_response
    [404, headers, []]
  end

  def no_formats_given_response
    [400, headers, ['Need time format instructions']]
  end

  def unknown_route?
    @request.get? && @request.path == '/time'
  end

  def formatted_time_response
    formatter = TimeFormatter.new(formats_from_request)
    if formatter.valid_formats?
      [200, headers, [formatter.datetime]]
    else
      [400, headers, ["Unknown time format [#{formatter.unknown_formats.join(', ')}]"]]
    end
  end

  def headers
    { 'Content-Type' => 'text/plain' }
  end

  def formats_from_request
    query_string_instructions = @request.query_string.split('&')
    query_string_instructions.select! { |s| s.start_with?('format=') }
    query_string_instructions.map! { |s| s.gsub('format=', '') }
    query_string_instructions.map! { |s| s.split(',') }
    query_string_instructions.flatten
  end

  def format_given?
    !!@request.query_string.index(/^format=./)
  end
end
