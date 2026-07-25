# frozen_string_literal: true

require "line/bot"

class RentAndUtilitiesReminder
  MESSAGE = "家賃, 光熱費を教えてくれ！"
  TIME_ZONE = ActiveSupport::TimeZone["Tokyo"]

  class << self
    def maybe_send(group_id:, client: nil)
      new(group_id:, client:).maybe_send
    end
  end

  def initialize(group_id:, client: nil)
    @group_id = group_id
    @client = client
  end

  def maybe_send
    return unless group_id
    return unless TIME_ZONE.today.day == 25
    return if Rails.cache.read(cache_key)

    push_message
    Rails.cache.write(cache_key, true, expires_in: 2.days)
  end

  private

  attr_reader :group_id

  def cache_key
    "rent_and_utilities_reminder:#{group_id}:#{TIME_ZONE.today}"
  end

  def push_message
    client.push_message(
      push_message_request: Line::Bot::V2::MessagingApi::PushMessageRequest.new(
        to: group_id,
        messages: [
          Line::Bot::V2::MessagingApi::TextMessage.new(text: MESSAGE)
        ]
      )
    )
  end

  def client
    @client ||= Line::Bot::V2::MessagingApi::ApiClient.new(
      channel_access_token: ENV["LINE_CHANNEL_TOKEN"]
    )
  end
end
