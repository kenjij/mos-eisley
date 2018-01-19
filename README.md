# mos-eisley

[![Gem Version](https://badge.fury.io/rb/mos-eisley.svg)](http://badge.fury.io/rb/mos-eisley) [![Code Climate](https://codeclimate.com/github/kenjij/mos-eisley/badges/gpa.svg)](https://codeclimate.com/github/kenjij/mos-eisley) [![security](https://hakiri.io/github/kenjij/mos-eisley/master.svg)](https://hakiri.io/github/kenjij/mos-eisley/master)

A Ruby based [Slack app](https://api.slack.com/slack-apps) server. It provides API endpoints to Slack as well as functions to access Slack API and manages events with handlers you create.

## Environment

- UNIX-like systems
- [Ruby](https://www.ruby-lang.org/) >= 2.1
- [Sinatra](http://www.sinatrarb.com/) ~> 2.0 – for inbound API server
- [em-http-request](https://github.com/igrigorik/em-http-request) ~> 1.1 – for outbound API access

## Getting Started

Install the gem.

    gem install mos-eisley

Create a configuration file and register some handlers. Handlers are your code that gets executed when events are received from Slack. See below for [more details](#).

Run Mos Eisley.

    mos-eisley -c config.rb start

## Setup

### Configuration File

This is a standard Ruby file and anything can go in it. It'll be executed at the very beginning of app launch, before the HTTP server is started. Here is an example.

```ruby
# Configure application logging
MosEisley.logger = Logger.new(STDOUT)
MosEisley.logger.level = Logger::DEBUG

# Main configuration block (MosEisley namespace can be abbrv. to ME)
ME::Config.setup do |c|
  # User custom data
  c.user = {my_data1: 'Something', my_data2: 'Somethingelse'}

  # HTTP server (Sinatra) settings
  c.dump_errors = true
  c.logging = true

  # Your handlers
  c.handler_paths = [
    'handlers'
  ]

  # Slack info
  c.verification_token = 'vErIf1c4t0k3n5'
  c.bot_access_token = 'xoxb-1234567890-b0t4cCe5sToK3N'
end
```

### Handlers

Define handlers, also a Ruby file, and they'll be executed as incoming Slack events are processed. You can define as many handlers as you want. You'll store the file(s) in the directory you've identified in the configuration file above.

There are 3 types of handlers you can define: `:action`, `:command`, `:event`, which corresponds to the MosEisley endpoints accordingly.

```ruby
ME::Handler.add(:event, 'debug') do |e, h|
  e.event.each { |k, v| puts "#{k}: #{v}" }
  h.stop unless e.for_me?
end

```

### Slack

Create an app in Slack to setup a bot. Following features can be setup.

- **Interactive Components** – Request URL should be set to MosEisley's `/action` endpoint.
- **Slash Commands** – Request URL should be set to MosEisley's `/command` endpoint.
- **OAuth & Permission** – This is where you get the Bot User OAuth Access Token you need to set in the configuration file.
- **Event Subscription** – Request URL should be set to MosEisley's `/event` endpoint. You'll likely Subscribe to Bot Events of `app_mention` or any of the `message.*` events.

## CLI Usage

To see help:

```
$ mos-eisley -h
Usage: mos-eisley [options] {start|stop}
  -c, --config=<s>     Load config from file
  -d, --daemonize      Run in the background
  -l, --log=<s>        Log output to file
  -P, --pid=<s>        Store PID to file
  -p, --port=<i>       Use port (default: 4567)
```

The minimum to start a server:

```
$ mos-eisley -c config.rb start
```
