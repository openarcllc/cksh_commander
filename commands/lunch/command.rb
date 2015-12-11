require "cksh_commander"
require "httparty"
require "json"

module Lunch
  class Command < CKSHCommander::Command
    set token: "YOUR_SLASH_COMMAND_TOKEN"

    # Keep track of who is in for lunch.
    INFILE = File.expand_path("../in.txt", __FILE__)

    desc "in", "State intention to attend the upcoming lunch."
    def in
      if user_in?
        set_response_text("You're already in!")
      else
        add_user
        set_response_text("You're in!")
      end
    end

    desc "out", "Revoke intention to attend the upcoming lunch."
    def out
      if !user_in?
        set_response_text("You aren't in, so you can't be out!")
      else
        remove_user
        set_response_text("You're out!")
      end
    end

    desc "who", "See who is attending the upcoming lunch."
    def who
      if attendees.any?
        content = "Those IN for lunch: "
        attendees.each_with_index do |a, i|
          content += username_from_slug(a)
          content += ", " unless i + 1 == attendees.count
        end
      else
        content = "No one has committed to lunch..."
      end

      set_response_text(content)
    end

    # Allow a user to send out a lunch reminder; this requires Slack
    # incoming webhook integration: https://api.slack.com/incoming-webhooks
    def remind
      payload = { text: "Lunch alert! Food in ~10 minutes!" }

      attendees.each do |a|
        # NOTE: Skip reminding the reminder...
        # next if a == userslug

        HTTParty.post(
          "YOUR_SLACK_WEBHOOK_URL",
          body: payload.merge({ channel: "@#{username_from_slug(a)}" }).to_json,
          headers: { "Content-Type" => "application/json" })
      end

      set_response_text(attendees.any? ? "Reminders sent!" : "No one to remind...")
    end

    private

    def attendees
      File.read(INFILE).split("\n")
    end

    def add_user(slug = nil)
      slug ||= userslug
      File.open(INFILE, 'a') { |f| f.write("#{slug}\n") }
    end

    def remove_user
      attending = attendees.dup
      File.open(INFILE, 'w')
      attending.dup.each do |a|
        add_user(a) if userslug != a && a.size > 1
      end
    end

    def user_in?
      attendees.include?(userslug)
    end

    def userslug
      "#{data.user_name}|#{data.user_id}"
    end

    def username_from_slug(slug)
      slug.split('|')[0]
    end
  end
end
