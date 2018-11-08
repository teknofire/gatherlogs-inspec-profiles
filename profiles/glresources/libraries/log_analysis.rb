class LogAnalysis < Inspec.resource(1)
  name 'log_analysis'
  desc 'Parse log files to find issues'

  attr_accessor :logfile, :search, :messages
  def initialize(log, expr, options = {})
    @options = options || {}
    @search = expr
    @logfile = log
    @messages = read_content
  end

  def hits
    @messages.count
  end

  def first
    @messages.first
  end

  def last
    @messages.last
  end

  def empty?
    @messages.empty?
  end

  # this is for use in the matchers so we can get a better UX with the latest
  # log entry text showing up in the verbose output
  def last_entry
    last || ''
  end

  def content
    @messages
  end

  def summary
    return '' if hits.zero?

    <<~EOS
      Found #{hits} messages about '#{search}'
      Last entry: #{last_entry}
    EOS
  end

  def exists?
    hits > 0
  end

  def log_exists?
    inspec.file(logfile).exist?
  end

  def to_s
    "log_analysis(#{logfile}, #{search})"
  end

  private

  def read_content
    cmd = []

    return [] unless File.exist?(logfile)

    flags = ''
    flags += '-i ' if @options[:case_sensitive] != true
    flags += inspec.os.family == 'darwin' ? '-E' : '-P'

    if @options[:a2service]
      cmd << "grep -i '#{@options[:a2service]}' #{logfile}"
      cmd << "grep #{flags} '#{search}'"
    else
      cmd << "grep #{flags} '#{search}' #{logfile}"
    end

    command = inspec.command(cmd.join(' | '))

    if command.exit_status > 1
      raise "#{cmd.join(' | ')} exited #{command.exit_status}\nERROR MSG: #{command.stderr}"
    end

    command.stdout.split("\n")
  end
end
