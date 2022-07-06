## PebblApp::Conf class definition

require 'pebbl_app'

require 'ostruct'
require 'optparse'
require 'forwardable'

class PebblApp::ConfigurationError < RuntimeError
end

class PebblApp::Conf

  module Scope
    DEFAULTS ||= 1
    ACTIVE ||= 2
    ## MANAGER ||= 4
    ## ALL ||= (DEFAULTS | ACTIVE | MANAGER)
    ALL ||= (DEFAULTS | ACTIVE)
  end

  include Enumerable
  extend Forwardable
  ## these forwarding methods assume that an @options object has been
  ## initialized to the instance
  def_delegators(:@options, :[], :[]=, :delete_field, :delete_field!,
                 :each_pair, :to_enum, :enum_for)

  ## initialize a new Conf object
  ##
  ## At least one of a command_name or command_name_block should be provided.
  ##
  ## If a command_name_block is provided, then the storage for the #command_name
  ## method will be be deferred until first access, at which time the
  ## command_name_block will be called to set and return the command_name for
  ## this Conf object.
  ##
  ## Else, if a command_name is provided, the string representation of the
  ## provided value will be used to provide the shell command name.
  ##
  ## Further details about the #command_name implementation are available in
  ## the documentation for that method.
  ##
  ## If neither a command_name_block nor command_name is provided, no command_name
  ## will be available for the Conf object.
  ##
  ## If an options value is provided, the value will be used when
  ## initializing the internal options struct for the Conf
  ## object. Else, the internal options struct will be initialized with
  ## an empty options set.
  ##
  def initialize(command_name = nil, options = nil, &command_name_block)
    if block_given?
      @command_name_block = command_name_block
      # if ! command_name.nil?
      #   Kernel.warn("Ignoring non-nil command_name (block provided)", uplevel: 0)
      # end
    elsif command_name
      @command_name = command_name.to_s
      ## else: @command_name will not be initialized here
    end
    @options = options ? OpenStruct.new(options) : OpenStruct.new
  end

  def default_blocks()
    @default_blocks ||= Hash.new
  end

  def map_default(name, &block)
    opt = name.to_sym
    if block_given?
      default_blocks[opt] = block
    else
      raise ArgumentError.new("No block provided")
    end
  end

  def mapped_default?(name)
    opt = name.to_sym
    default_blocks.key?(opt)
  end

  def unmap_default(name)
    opt = name.to_sym
    default_blocks.delete(opt)
  end

  def option_default(name)
    opt = name.to_sym
    if mapped_default?(name)
      default_blocks[opt].call
    else
      false
    end
  end

  ## Return any command_name initialized to this Conf object
  ##
  ## If the @command_name instance variable has been initialized for the
  ## instance, that instance variable's value will be returned.
  ##
  ## Else, if the Conf object was initialized with a command_name_block
  ## and the  @command_name instance variable is uninitialized for the
  ## instance, this Conf object will be yielded to the
  ## command_name_block,. The string representation of the block's return
  ## value will be stored and returned as the command_name for this Conf
  ## object.
  ##
  ## If no command_name has been stored and no command_name_block was provided,
  ## this method will return an empty string.
  ##
  ## This method's return value will be used in the default
  ## implementation of the #configure_option_parser method, mainly for
  ## producing a help banner.
  ##
  def command_name
    if self.instance_variable_defined?(:@command_name)
      return @command_name
    elsif self.instance_variable_defined?(:@command_name_block)
      return @command_name = @command_name_block.yield(self).to_s
    else
      return "".freeze
    end
  end

  ## Return the options struct for this Conf object
  ##
  ## This value may be used for setting default configuration values,
  ## storing values from parsed shell options uncer
  ## config_option_parser, and generally  configuring this Conf
  ## object.
  ##
  ## @return [OpenStruct] the options struct
  def options
    @options ||= OpenStruct.new
  end

  ## If an option has been configured for the provided name in the
  ## #options struct, return true, else return false
  ##
  ## @param name [String, Symbol] the option name.
  ##
  ## @return [boolean] a truthiness value indicating whether the option
  ##         has been configured
  def option?(name)
    sname = name.to_sym
    self.options.each_pair do |opt, v|
      if opt.eql?(sname)
        return true
      end
    end
    return false
  end

  def set_option(name, value)
    self.options[name] = value
  end

  ## remove a named option from the instance
  ##
  ## @param name [String, Symbol] the option name.
  ##
  def deconfigure(name)
    if self.option?(name)
      self.options.delete_field(name)
    end
  end

  ## return the value of a named option for the instance, if configured
  ## to the instance.
  ##
  ## If the named option is not configured to the instance, then if a
  ## fallback block is provided, the symbol name of the option will be
  ## yielded to the block. The value returned by the block will be the
  ## value returned by this method.
  ##
  ## If the named option is not configured to the instance and no
  ## fallback block is provided, the default value will be returned.
  ##
  ## @param name [String, Symbol] the option name.
  ## @param default [Any] a default value for the option, returned only if
  ##        no fallback is provided
  ## @param fallback [Proc] a block, lambda, or other proc form, to be
  ##        called if no option has been configured for the provided
  ##        name.
  def option(name, default = false, &fallback)
    opt = name.to_sym
    if self.option?(opt)
      return self.options[opt]
    elsif block_given?
      fallback.yield(opt)
    else
      return default
    end
  end

  ## create, configure, and return a new argv option parser for this
  ## application.
  ##
  ## The new option parser will be configured before return, using
  ## #configure_option_parser
  ##
  ## @return [OptionParser] the configured option parser
  def make_option_parser()
    OptionParser.new do |parser|
      configure_option_parser(parser)
    end
  end

  ## configure an argv option parser for this application
  ##
  ## implementing classes may override this method. Any overriding
  ## method should usally dispatch to the superclass' method before
  ## return.
  ##
  ## @param parser [OptionParser] the parser to configure
  def configure_option_parser(parser)
    cmd = self.command_name
    parser.program_name = cmd
    parser.banner = "Usage: #{cmd} [options]"
    parser.separator "".freeze
    parser.separator "Options:"
    parser.on_head("-h", "--help", "Show this help") do
      puts parser
      exit unless self.option(:persist)
    end
  end

  ## parse the array of command line arguments, using an option parser
  ## created by #make_option_parser.
  ##
  ## The provided argv array may be destructively modified, such that
  ## the value after return will include only unparsed, non-option
  ## arguments e.g filenames.
  ##
  def parse_opts!(argv = ARGV)
    parser = self.make_option_parser()
    parser.parse!(argv)
  end

  ## return the set of parsed args for this instance, or a new
  ## empty array if no value was previously bound
  def parsed_args()
    @parsed_args ||= []
  end

  ## set the array of parsed args for this instance
  def parsed_args=(value)
    @parsed_args=value
  end

  ## configure this instance, parsing any options provided in argv
  ## then setting this instance's parsed_args field to the resulting
  ## value of argv.
  ##
  ## The argv value may be destructively modifed within this method,
  ## as by #parse_opts!
  ##
  ## @param argv [Array<String>] options for this instance, using a
  ##        shell command string syntax for the set of options
  def configure(argv: ARGV)
    self.parse_opts!(argv)
    self.parsed_args = argv
  end

end
