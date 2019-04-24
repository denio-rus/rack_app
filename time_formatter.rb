class TimeFormatter
  attr_reader :unknown_formats

  KNOWN_FORMATS = { 'year' => '%Y', 'month' => '%m', 'day' => '%d',
                    'hour' => '%H', 'minute' => '%M', 'second' => '%S' }.freeze

  def initialize(given_formats)
    @answer_formats, @unknown_formats = given_formats.partition { |format| KNOWN_FORMATS.key?(format) }
  end

  def datetime
    Time.now.strftime(format_directives)
  end

  def valid_formats?
    @unknown_formats.empty?
  end

  private

  def format_directives
    @answer_formats.map(&KNOWN_FORMATS).join('-')
  end
end
