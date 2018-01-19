require 'thin'
require 'sinatra/base'
require 'http-server/helper'

module MosEisley

  # The Sinatra server
  class Server < Sinatra::Base

    helpers Helper

    configure do
      set :environment, :production
      c = Config.shared
      set :dump_errors, c.dump_errors
      set :logging, c.logging
      WebAPI.auth_test
      c.run_post_boot
    end

    before do
    end

    # Interactive message buttons
    # Receive POST form with payload containing JSON string; use "token" to verify
    post '/action' do
      logger.info('Incoming request received at /action.')
      logger.debug("Body size: #{request.content_length} bytes")
      event = parse_json(params[:payload])
      halt 400 if event.nil?
      logger.debug("Parsed JSON data:\n#{event}")
      unless valid_token?(event[:token])
        logger.warn("Invalid Slack Events token: #{event[:token]}")
        halt 401
      end
      res = Handler.run(:action, S3PO.create_event(event, :action))
      if res
        json_with_object(res)
      else
        200
      end
    end

    # Slash commands
    # Receive POST form; use "token" to verify
    # Respond within 3 sec directly; raw text or formatted
    # OR, use response_url
    post '/command' do
      logger.info('Incoming request received at /command.')
      cmd = parse_command(params)
      unless valid_token?(cmd[:token])
        logger.warn("Invalid Slack Events token: #{cmd[:token]}")
        halt 401
      end
      res = Handler.run(:command, cmd)
      if res
        json_with_object(res)
      else
        200
      end
    end

    # Event API
    # Receive POST JSON; use "token" to verify
    post '/event' do
      logger.info('Incoming request received at /event.')
      logger.debug("Body size: #{request.content_length} bytes")
      request.body.rewind
      event = parse_json(request.body.read)
      halt 400 if event.nil?
      logger.debug("Parsed JSON data:\n#{event}")
      
      unless valid_token?(event[:token])
        logger.warn("Invalid Slack Events token: #{event[:token]}")
        halt 401
      end
      resp = {}
      case event[:type]
      when 'url_verification'
        resp[:challenge] = event[:challenge]
      when 'event_callback'
        Handler.run(:event, S3PO.create_event(event[:event]))
        resp[:text] = 'OK'
      else
        resp[:text] = "Unknown event type: #{event[:type]}"
      end
      json_with_object(resp)
    end

    not_found do
      logger.info('Invalid request.')
      logger.debug("Request method and path: #{request.request_method} #{request.path}")
      json_with_object({message: 'Huh, nothing here.'})
    end

    error 400 do
      json_with_object({message: 'Um, I did not get that.'})
    end

    error 401 do
      json_with_object({message: 'Oops, need a valid token.'})
    end

    error do
      status 500
      err = env['sinatra.error']
      logger.error "#{err.class.name} - #{err}"
      json_with_object({message: 'Yikes, internal error.'})
    end

    after do
      content_type 'application/json'
    end

  end
end
