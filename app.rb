class App
  KNOWN_FORMATS = { 'year' => '%Y', 'month' => '%m', 'day' => '%d',
                    'hour' => '%H', 'minute' => '%M', 'second' => '%S' }.freeze

  def call(env)
    @env = env
    @unknown_formats = []
    @answer_formats = []

    analyze_request_for_directives if need_time?

    [status, headers, body]
  end

  def need_time?
    @env['REQUEST_METHOD'] == 'GET' && @env['REQUEST_PATH'] == '/time'
  end

  def status
    return 404 unless need_time?

    unknown_formats? ? 400 : 200
  end

  def headers
    { 'Content-Type' => 'text-plain' }
  end

  def body
    return [] unless need_time?

    [] << make_respond_body
  end

  def make_respond_body
    return "Unknown time format [#{@unknown_formats.join(', ')}]" if unknown_formats?

    format_directives = @answer_formats.join('-')
    Time.now.strftime(format_directives)
  end

  def analyze_request_for_directives
    return unless format_given?

    formats_from_request.each do |format|
      if KNOWN_FORMATS.key?(format)
        @answer_formats << KNOWN_FORMATS[format]
      else
        @unknown_formats << format
      end
    end
  end

  def format_given?
    !!@env['QUERY_STRING'].index(/^format=/)
  end

  def formats_from_request
    string = @env['QUERY_STRING'].split('&')
    string.select! { |s| s.start_with?('format=') }
    string.map! { |s| s.gsub('format=', '') }
    string.map! { |s| s.split(',') }
    string.flatten
  end

  def unknown_formats?
    @unknown_formats.any?
  end
end
