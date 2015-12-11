## :stars: Sla[CK] Sla[SH] Commander

[![License](https://img.shields.io/packagist/l/doctrine/orm.svg)]()

CKSHCommander is a Ruby gem that simplifies the task of processing [Slack slash
commands](https://api.slack.com/slash-commands). It provides a class-based
convention for authoring command handlers, and it supports basic subcommands and
arguments. Check out the
[cksh_command_api](https://github.com/openarcllc/cksh_commander_api) repository to see a dead simple Sinatra API
that comes bootstrapped with everything you need to process Slack slash
commands using this gem.

### Installation

You can install `cksh_commander` via RubyGems. In your Gemfile:

```ruby
gem 'cksh_commander'
```

Or from a command line:

```
gem install cksh_commander
```

### Usage

Defining a custom command is easy. First, create a `commands/` directory and tell
`CKSHCommander` where it can find your commands. Let's say we've created a `commands/`
directory at the root of our project. Our configuration is as follows:

```ruby
# app.rb

require 'cksh_commander'

CKSHCommander.configure do |c|
  c.commands_path = File.expand_path("../commands", __FILE__)
end
```

Now, let's assume that we've set up an `/example` Slack command. We want to create
a directory-based container for everything that our command might interact
with. (For example, we may wish to log some command-specific data in a text file.)
All that we have to do is to create a directory under our `commands/` directory
that matches the name of the slash command. In this case:

```
root/
  app.rb
  commands/
    example/
      command.rb
  ...
```

The last step is to create our custom command class. We name this class `Command` to
abide by the convention. We define our class as follows. Note that the class must inherit from
`CKSHCommander::Command`, and it should reside within a module that shares
its name with the command.

```ruby
# commands/example/command.rb

require "cksh_commander"

module Example
  class Command < CKSHCommander::Command
    set token: "gIkuvaNzQIHg97ATvDxqgjtO"

    # Subcommand with no arguments
    # SLACK: /example test0
    desc "test0", "Subcommand 0 description."
    def test0
      set_response_text("Subcommand: test0")
    end

    # Subcommand with one argument
    # SLACK: /example test1 text
    desc "test1 [TEXT]", "Subcommand 1 description."
    def test1(text)
      set_response_text("Subcommand: test1; Text: #{text}")
    end

    # No subcommand with one argument
    # SLACK: /example text
    desc "[TEXT]", "Root command description."
    def ___(text)
      set_response_text("Root command; Text: #{text}")
    end
  end
end
```

We set our slash command authentication token at the class level, and define
methods for processing subcommands. Attachments (which take the form of a hash)
can be added using `add_response_attachment(attachment)`. You can also set the
response to `'in_channel'` at the method level with `respond_in_channel!`.

We can access the Slack payload data via the `data` reader.

```ruby
data.token          #=> "gIkuvaNzQIHg97ATvDxqgjtO"
data.team_id        #=> "T0001"
data.team_domain    #=> "example"
data.channel_id     #=> "C2147483705"
data.channel_name   #=> "test"
data.user_id        #=> "U2147483697"
data.user_name      #=> "Randy"
data.command        #=> "/test"
data.text           #=> "subcommand"
data.response_url   #=> "https://hooks.slack.com/commands/1234/5678"
```

Similar to [Thor](http://whatisthor.com/), we are able to document our
command's API with the class-level `desc` method—as is shown in the example
above. CKSHCommander provides a `help` subcommand out of the box, and this will
echo the documentation back to the Slack user.

```
/example test0         # Subcommand 0 description.
/example test1 [TEXT]  # Subcommand 1 description.
/example [TEXT]        # Root command description.
```

To run a command, we use `CKSHCommander::Runner`. In the example below, we've
created a [simple Sinatra app](https://github.com/openarcllc/cksh_commander_api)
to illustrate its usage with the standard Slack slash command payload.

```ruby
# app.rb

require "sinatra"
require "json"
require "cksh_commander"

CKSHCommander.configure do |c|
  c.commands_path = File.expand_path("../commands", __FILE__)
end

post "/" do
  content_type :json

  command = params["command"][1..-1]
  response = CKSHCommander::Runner.run(command, params)
  JSON.dump(response.serialize)
end
```

### Examples

Check out (and/or use) [example commands provided by the
community](https://github.com/openarcllc/cksh_commander/tree/master/commands).
Want to contribute a command? Great! Add your command to the `commands/` directory
and open a pull request! The implementations below provide convenient reference
points.

| command | description |
| --------|--------------- |
| [jira](https://github.com/openarcllc/cksh_commander/tree/master/commands/jira)  | Display JIRA issue details in a Slack channel or message. |
| [lunch](https://github.com/openarcllc/cksh_commander/tree/master/commands/lunch) | State or revoke your intention to attend the weekly lunch gathering. |

### Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/openarcllc/cksh_commander.
