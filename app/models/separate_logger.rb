class SeparateLogger < ActiveSupport::Logger
  attr_accessor :error_log

  def initialize(*args)
    super(*args)
    @error_log = Logger.new(Rails.root.join('log', 'errors.log'), 1, 50 * 1024 * 1024)
    @not_found_log = Logger.new(Rails.root.join('log', 'not_found.log'), 1, 50 * 1024 * 1024)
  end

  def error(progname = nil, &block)
    str = clear(progname)
    @error_log.info(str, &block) unless str.nil?
    super
  end

  def not_found(msg)
    @not_found_log.info(msg)
  end

  def fatal(progname = nil, &block)
    str = clear(progname)
    @error_log.info(str, &block) unless str.nil?
    super
  end

  protected
  def clear(progname)
    if progname.split("\n").size > 1
      log_str = progname.split("\n").delete_if { |s| s[/\.rb:\d+:in/] and s[/\slib\/.*\.rb:\d+:in\s/] }.join("\n")
      log_str+="\n" unless log_str.ends_with?("\n")
      log_str
    else
      if progname.empty? or (progname[/\.rb:\d+:in/] and progname[/\slib\/.*\.rb:\d+:in\s/])
        nil
      else
        progname
      end
    end
  end
end