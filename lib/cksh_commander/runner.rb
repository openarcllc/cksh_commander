require "cksh_commander/data"
require "cksh_commander/response"

module CKSHCommander
  class Runner
    def self.run(command, params)
      require_constants!
      data = CKSHCommander::Data.new(params)

      begin
        name = "#{command.capitalize}::Command"
        cmd = Kernel.const_get(name).new(data)

        response = cmd.authenticated? ? cmd.run : Response.new("Invalid token!")
      rescue => e
        text = cmd && cmd.debugging? ? e.message :
          cmd ? cmd.error_message : "Command not found..."
        response = Response.new(text)
      end

      response
    end

    private_class_method def self.require_constants!
      commands_path = CKSHCommander.config.commands_path
      Dir["#{commands_path}/**/*.rb"].each {|file| require file }
    end
  end
end
