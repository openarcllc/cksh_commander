require "cksh_commander/response"

module CKSHCommander
  class Command
    class << self
      attr_accessor :token
      attr_reader :docs

      def set(opts)
        opts.each do |k,v|
          send("#{k}=", v) if respond_to?("#{k}=")
        end
      end

      # Define command usage/description documentation
      # for output in 'help' command.
      def desc(usage, description)
        @docs ||= []
        @docs << { usage: usage, desc: description }
      end
    end

    attr_accessor :data

    def initialize(data = nil)
      @data = data
      @response = Response.new
    end

    def run
      # Find subcommands that match the provided text.
      underscored_text = @data.text.gsub(/\s/, '_')
      matched_subcommands = subcommand_methods.select { |command|
        underscored_text.match(Regexp.new("\\A#{command}"))
      }

      # Add the "missing" subcommand if our command object
      # responds to it and we have no matched subcommands.
      matched_subcommands << "___" if respond_to?("___") && matched_subcommands.empty?

      if matched_subcommands.empty?
        return Response.new("Cannot find the provided subcommand!")
      end

      # Use the longest matching subcommand. Fetch the subcommand
      # method and its arity. Represent the original subcommand string.
      subcommand = matched_subcommands.max_by(&:size).to_s
      subcommand_m = method(subcommand)
      subcommand_a = subcommand_m.arity.abs
      subcommand_o = subcommand.gsub(/_/, ' ')

      # Get argument string and slurp up arguments using arity. We
      # assume that only trailing arguments can be space-delimited.
      argstr, args = @data.text.gsub(subcommand_o, '').strip, []
      subcommand_a.times do |i|
        if i + 1 == subcommand_a
          args << (argstr.empty? ? nil : argstr)
        else
          arg = argstr.split(' ')[0]
          argstr.gsub!(Regexp.new("\\A#{arg}\s?"), '')
          args << arg
        end
      end

      if args.size != subcommand_a
        return Response.new("Wrong number of arguments (#{args.size} for #{subcommand_a})")
      end

      send(subcommand, *args)
      @response
    end

    def help
      if self.class.docs.any?
        set_response_text(help_output)
      else
        set_response_text("Add some documentation!")
      end
    end

    def authenticated?
      self.class.token && self.class.token == data.token
    end

    def set_response_text(text)
      @response.text = text
    end

    def add_response_attachment(attachment)
      unless attachment.is_a?(Hash)
        raise ArgumentError, "Attachment must be a Hash"
      end

      @response.attachments << attachment
    end

    def respond_in_channel!
      @response.type = 'in_channel'
    end

    private

    def subcommand_methods
      custom = (methods - CKSHCommander::Command.new.methods)
      custom.concat([:help])
    end

    def help_output
      docs = self.class.docs
      output = "```\n"

      # Ensure that descriptions are justified properly.
      just = docs.max_by { |d|
        d[:usage].size
      }[:usage].size + @data.command.size + 3

      # Add output for each documented command.
      docs.each do |d|
        output += "#{@data.command} #{d[:usage]}".ljust(just) + "# #{d[:desc]}\n"
      end

      output += "```"
    end
  end
end
