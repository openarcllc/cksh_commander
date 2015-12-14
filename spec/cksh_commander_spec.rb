require 'spec_helper'

describe CKSHCommander do
  paramstub = {
    "token" => "gIkuvaNzQIHg97ATvDxqgjtO",
    "team_id" => "T0001",
    "team_domain" => "example",
    "channel_id" => "C2147483705",
    "channel_name" => "test",
    "user_id" => "U2147483697",
    "user_name" => "Randy",
    "command" => "/test",
    "text" => "",
    "response_url" => "https://hooks.slack.example.com/commands/1234/5678"
  }

  it 'has a version number' do
    expect(CKSHCommander::VERSION).not_to be nil
  end

  it 'can be configured' do
    path = File.expand_path("../commands", __FILE__)

    CKSHCommander.configure do |c|
      c.commands_path = path
    end

    expect(CKSHCommander.config.commands_path).to eq(path)
  end

  it 'authenticates at the command level' do
    params = paramstub.merge({ "token" => "invalid" })
    response = CKSHCommander::Runner.run("test", params)
    expect(response.text).to eq("Invalid token!")
  end

  it 'forwards the empty subcommand to ___ with one arg' do
    params = paramstub.merge({ "text" => "yes" })
    response = CKSHCommander::Runner.run("test", params)
    expect(response.text).to eq("___: yes")
  end

  it 'runs a test subcommand' do
    params = paramstub.merge({ "text" => "test0" })
    response = CKSHCommander::Runner.run("test", params)
    expect(response.text).to eq("Test 0")
  end

  it 'runs a test subcommand with one argument' do
    params = paramstub.merge({ "text" => "test1 awesome" })
    response = CKSHCommander::Runner.run("test", params)
    expect(response.text).to eq("Test 1: awesome")
  end

  it 'runs test subcommand with two arguments' do
    params = paramstub.merge({ "text" => "test2 awesome sauce" })
    response = CKSHCommander::Runner.run("test", params)
    expect(response.text).to eq("Test 2: awesomesauce")
  end

  it 'runs a test subcommand with three arguments, the last being spaced' do
    spaced = "on desolation row"
    params = paramstub.merge({ "text" => "test3 awesome sauce #{spaced}" })
    response = CKSHCommander::Runner.run("test", params)
    expect(response.text).to eq("Test 3: awesomesauce #{spaced}")
  end

  it 'runs a test command with optional arguments' do
    params = paramstub.merge({ "text" => "test4 awesome" })
    response = CKSHCommander::Runner.run("test", params)
    expect(response.text).to eq("Test 4: awesome")

    params = paramstub.merge({ "text" => "test4 awesome sauce" })
    response = CKSHCommander::Runner.run("test", params)
    expect(response.text).to eq("Test 4: sauce")
  end

  it 'provides the correct output for the "help" subcommand' do
    params = paramstub.merge({ "text" => "help" })
    response = CKSHCommander::Runner.run("test", params)

    expected = "```\n"
    expected += "/test test0         # Description.\n"
    expected += "/test test1 [TEXT]  # Description.\n"
    expected += "```"

    expect(response.text).to eq(expected)
  end

  it 'performs user ID authorization at the subcommand level' do
    params = paramstub.merge({ "text" => "testprivate" })
    response = CKSHCommander::Runner.run("test", params)
    expect(response.text).to eq("You are unauthorized to use this subcommand!")

    params = params.merge({ "user_id" => "AUTHORIZED" })
    response = CKSHCommander::Runner.run("test", params)
    expect(response.text).to eq("You are authorized!")
  end
end
