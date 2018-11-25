class App
  KNOWN_FORMATS = { 'year' => '%Y', 'month' => '%m', 'day' => '%d',
                    'hour' => '%H', 'minute' => '%M', 'second' => '%S' }.freeze

  def call(env)
    @request = Rack::Request.new(env)

    return [404, headers, []] unless need_time?

    @response = FormatedTimeString.new(@request)
    [status, headers, body]
  end

  private

  def need_time?
    @request.get? && @request.path == '/time'
  end

  def status
    @response.unknown_formats? ? 400 : 200
  end

  def headers
    { 'Content-Type' => 'text/plain' }
  end

  def body
    [] << @response.make
  end

  class FormatedTimeString
    def initialize(request)
      @request = request
      @unknown_formats = []
      @answer_formats = []
    end

    def make
      return 'Need time format instructions' unless format_given?

      analyze_request_for_directives
      return "Unknown time format [#{@unknown_formats.join(', ')}]" if unknown_formats?

      format_directives = @answer_formats.join('-')
      Time.now.strftime(format_directives)
    end

    def unknown_formats?
      @unknown_formats.any?
    end

    private

    def analyze_request_for_directives
      formats_from_request.each do |format|
        if KNOWN_FORMATS.key?(format)
          @answer_formats << KNOWN_FORMATS[format]
        else
          @unknown_formats << format
        end
      end
    end

    def format_given?
      !!@request.query_string.index(/^format=./)
    end

    def formats_from_request
      query_string_instructions = @request.query_string.split('&')
      query_string_instructions.select! { |s| s.start_with?('format=') }
      query_string_instructions.map! { |s| s.gsub('format=', '') }
      query_string_instructions.map! { |s| s.split(',') }
      query_string_instructions.flatten
    end
  end
end
