# frozen_string_literal: true

class BaseCommand
  class << self
    def match?(text)
      self::PATTERN.match?(text)
    end

    def call(line_user_id:, group_id:, text:)
      new(line_user_id:, group_id:, match_data: self::PATTERN.match(text)).call
    end
  end

  def initialize(line_user_id:, group_id:, match_data:)
    @line_user_id = line_user_id
    @group_id = group_id
    @match_data = match_data
  end

  def call
    raise NotImplementedError
  end

  private

  attr_reader :line_user_id, :group_id, :match_data

  def display_name(user_id)
    messaging_client.get_group_member_profile(group_id:, user_id:).display_name
  end

  def messaging_client
    @messaging_client ||= Line::Bot::V2::MessagingApi::ApiClient.new(
      channel_access_token: ENV["LINE_CHANNEL_TOKEN"]
    )
  end
end
