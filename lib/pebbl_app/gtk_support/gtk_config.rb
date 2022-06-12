## GtkConfig for Pebbl App

require 'pebbl_app/support/config'

require 'optparse'

class PebblApp::GtkSupport::GtkConfig < PebblApp::Support::Config

  ## set a display option for this instance
  ##
  ## This method will not modify the process environment.
  ##
  ## If a display option is provided for the application, the
  ## application should ensure that any authentication methods required
  ## for connecting to the display will be configured and available to
  ## the application, at runtime.
  def display=(dpy)
    ## set the display, independent of parse_opts
    self.options[:display] = dpy
  end

  ## if a display option has been set for this instance, return the
  ## value as initialized for that configuration option. Else, if a
  ## 'DISPLAY' value is configured in the process environment, return
  ## that value. Else, return false
  def display()
    if self.option?(:display)
      self.options[:display]
    elsif (dpy = ENV['DISPLAY'])
      dpy
    else
      false
    end
  end

  ## if a display option has been set for this instance, remove
  ## that configuration option.
  ##
  ## This method will not modify the process environment.
  def unset_display()
    self.deconfigure(:display)
  end

  ## return true if a display has been configured for this instance,
  ## or if there is a 'DISPLAY' value configured in the process
  ## environment
  def display?()
    self.option?(:display) ||
      ENV.has_key?('DISPLAY')
  end

  ## configure an argv options parser for this instance
  ##
  ## @param parser [OptionParser] the parser to configure
  def configure_option_parser(parser)
    parser.on("-d", "--display DISPLAY",
              "X Window System Display, overriding DISPLAY") do |dpy|
      self.display = dpy
    end
  end

  ## return an array of arguments for Gtk.init, as initialized under
  ## the #configure method for this instance
  ##
  ## @return [Array] the arguments for Gtk.init
  def gtk_args()
    args = self.parsed_args.dup
    if ! self.display?
      raise PebblApp::GtkSupport::ConfigurationError.new("No display configured")
    elsif self.option?(:display)
      args.push(%(--display))
      args.push(self.option(:display))
    end
    return args
  end

end

