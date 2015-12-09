module CKSHCommander
  class Data
    def initialize(params)
      command_args.each do |arg|
        instance_variable_set("@#{arg}", params.fetch(arg))
        self.class.send(:attr_reader, arg)
      end
    end

    private

    def command_args
      %w[
        token
        team_id
        team_domain
        channel_id
        channel_name
        user_id
        user_name
        command
        text
        response_url
      ]
    end
  end
end
