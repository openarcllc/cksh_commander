module CKSHCommander
  class Response
    attr_accessor :text, :type, :attachments

    def initialize(text = "")
      @text = text
      @type = ""
      @attachments = []
    end

    def serialize
      {
        text: @text,
        response_type: @type,
        attachments: @attachments
      }
    end
  end
end
