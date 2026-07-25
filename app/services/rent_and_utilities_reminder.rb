# frozen_string_literal: true

require "line/bot"

class RentAndUtilitiesReminder
  MESSAGE = "家賃, 光熱費を教えてくれ！"
  TIME_ZONE = ActiveSupport::TimeZone["Tokyo"]

  class << self
    def call(force: false, client: nil)
      new(force:, client:).call
    end
  end

  def initialize(force: false, client: nil)
    @force = force
    @client = client
  end

  def call
    return 0 unless force || reminder_day?

    group_ids.sum do |group_id|
      push_message(group_id) ? 1 : 0
    end
  end

  private

  attr_reader :force

  def reminder_day?
    TIME_ZONE.today.day == 25
  end

  def group_ids
    ids = Payment.where.not(group_id: nil).distinct.pluck(:group_id)
    ids = [ ENV["LINE_GROUP_ID"] ] if ids.empty? && ENV["LINE_GROUP_ID"].present?
    ids
  end

  def push_message(group_id)
    client.push_message(
      push_message_request: Line::Bot::V2::MessagingApi::PushMessageRequest.new(
        to: group_id,
        messages: [
          Line::Bot::V2::MessagingApi::TextMessage.new(text: MESSAGE)
        ]
      )
    )
    true
  rescue StandardError => e
    Rails.logger.error("[RentAndUtilitiesReminder] failed to push to #{group_id}: #{e.message}")
    false
  end

  def client
    @client ||= Line::Bot::V2::MessagingApi::ApiClient.new(
      channel_access_token: ENV["LINE_CHANNEL_TOKEN"]
    )
  end
end
