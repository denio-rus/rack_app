class TimeFormatter
  attr_reader :unknown_formats

  KNOWN_FORMATS = { 'year' => '%Y', 'month' => '%m', 'day' => '%d',
                    'hour' => '%H', 'minute' => '%M', 'second' => '%S' }.freeze

  def initialize(given_formats)
    @unknown_formats = []
    @answer_formats = []
    analyze_formats(given_formats)
  end

  def datetime
    Time.now.strftime(format_directives)
  end

  def valid_formats?
    @unknown_formats.empty?
  end

  private

  def format_directives
    chosen_formats = KNOWN_FORMATS.select { |k| @answer_formats.include?(k) }
    chosen_formats.values.join('-')
  end

  def analyze_formats(given_formats)
    sorted_formats = given_formats.partition { |format| KNOWN_FORMATS.key?(format) }
    @answer_formats = sorted_formats[0]
    @unknown_formats = sorted_formats[1]
  end
end
