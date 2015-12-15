require "cksh_commander/command"
require "cksh_commander/data"
require "cksh_commander/response"
require "cksh_commander/runner"
require "cksh_commander/version"

module CKSHCommander
  class << self
    attr_accessor :config

    def config
      @config ||= Configuration.new
    end

    def configure
      yield config
    end
  end

  class Configuration
    attr_accessor :commands_path

    def initialize
      @commands_path = "../commands"
    end
  end
end
