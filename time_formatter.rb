class TimeFormatter
  attr_reader :unknown_formats

  KNOWN_FORMATS = { 'year' => '%Y', 'month' => '%m', 'day' => '%d',
    'hour' => '%H', 'minute' => '%M', 'second' => '%S' }.freeze

  def initialize(given_formats)
    @given_formats = given_formats
    @unknown_formats = []
    @answer_formats = []
    analyze_formats
  end

  def datetime
    format_directives = @answer_formats.join('-')
    Time.now.strftime(format_directives)
  end

  def valid_formats?
    @unknown_formats.empty?
  end

  private

  def analyze_formats
    @given_formats.each do |format|
      if KNOWN_FORMATS.key?(format)
        @answer_formats << KNOWN_FORMATS[format]
      else
        @unknown_formats << format
      end
    end
  end
end
