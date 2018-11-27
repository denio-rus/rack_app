require_relative 'time_formatter'

class App
  def call(env)
    @request = Rack::Request.new(env)

    return not_found_response if unknown_route?
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
    !@request.get? || @request.path != '/time'
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
    @request.GET['format'].split(',').map(&:strip)
  end

  def format_given?
    @request.GET.key?('format') && !@request.GET['format'].strip.empty?
  end
end
