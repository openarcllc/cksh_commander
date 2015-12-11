require "cksh_commander"
require "jira"

module Jira
  class Command < CKSHCommander::Command
    set token: "YOUR_SLASH_COMMAND_TOKEN"

    # Location of your JIRA instance
    JIRABASE = "http://localhost:3000/jira"

    desc "issues [PROJECT] [STATUS]", "Get project issues."
    def issues(project, status = nil)
      content = "Issues for project: *#{project.upcase}*\n\n"

      begin
        issues = get_issues(project, status)
        if issues.any?
          issueoutput = issues.map { |i| issue_output(i) }.join("\n")
          respond_in_channel!
          add_response_attachment({
            text: issueoutput, mrkdwn_in: ['text'], color: 'good'
          })
        else
          content += "No matching issues found..."
        end
      rescue
        content = "Encountered an error..."
      end

      set_response_text(content)
    end

    desc "[TICKET]", "Get ticket details."
    def ___(issueid)
      begin
        issue = client.Issue.find(issueid)
        set_response_text(issue_output(issue))
        respond_in_channel!
      rescue
        set_response_text("Cannot find issue!")
      end
    end

    private

    def client
      @jira ||= JIRA::Client.new({
        username: "YOUR_JIRA_SYSTEM_USERNAME",
        password: "YOUR_JIRA_SYSTEM_PASSWORD",
        site: JIRABASE,
        auth_type: :basic,
        context_path: ""
      })
    end

    def get_issues(project, status)
      query = "project = #{project}"
      query += " AND status = \"#{status}\"" if status

      client.Issue.jql(query, {
        startAt: 0,
        max: 50,
        fields: %w[summary assignee status issuetype key]
      })
    end

    def issue_output(issue)
      output = "<#{JIRABASE}/browse/#{issue.key}|*#{issue.key}*: #{issue.summary}>\n"
      output += "*Type*: #{issue.fields['issuetype']['name']}\n"
      output += "*Assignee*: #{assignee_output(issue.fields['assignee'])}\n"
      output += "*Status*: #{issue.fields['status']['name']}\n"
    end

    def assignee_output(assignee)
      return "Not Assigned" unless assignee
      "#{assignee["displayName"]} " +
        "<#{user_email(assignee["emailAddress"])}>"
    end

    def user_email(address)
      "<mailto:#{address}|#{address}>"
    end
  end
end
