# frozen_string_literal: true

require "line/bot"

class WebhookController < ApplicationController
  COMMANDS = [ RecordPaymentCommand ].freeze

  allow_unauthenticated_access
  protect_from_forgery except: [ :callback ]

  def callback
    body = request.body.read
    signature = request.env["HTTP_X_LINE_SIGNATURE"]

    begin
      events = parser.parse(body:, signature:)
    rescue Line::Bot::V2::WebhookParser::InvalidSignatureError
      head :bad_request
      return
    end

    events.each do |event|
      case event
      when Line::Bot::V2::Webhook::MessageEvent
        case event.message
        when Line::Bot::V2::Webhook::TextMessageContent
          text = event.message.text.strip
          line_user_id = event.source.user_id

          command_class = COMMANDS.find { |cmd| cmd.match?(text) }
          next unless command_class

          reply_text = command_class.call(line_user_id:, text:)

          reply = Line::Bot::V2::MessagingApi::ReplyMessageRequest.new(
            reply_token: event.reply_token,
            messages: [
              Line::Bot::V2::MessagingApi::TextMessage.new(text: reply_text)
            ]
          )
          client.reply_message(reply_message_request: reply)
        end
      end
    end

    head :ok
  end

  private

  def client
    @client ||= Line::Bot::V2::MessagingApi::ApiClient.new(
      channel_access_token: ENV["LINE_CHANNEL_TOKEN"]
    )
  end

  def parser
    @parser ||= Line::Bot::V2::WebhookParser.new(channel_secret: ENV["LINE_CHANNEL_SECRET"])
  end
end
