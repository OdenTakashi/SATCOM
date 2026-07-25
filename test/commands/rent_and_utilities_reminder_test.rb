# frozen_string_literal: true

require "test_helper"

class RentAndUtilitiesReminderTest < ActiveSupport::TestCase
  class FakeClient
    attr_reader :requests

    def initialize
      @requests = []
    end

    def push_message(push_message_request:)
      @requests << push_message_request
    end
  end

  setup do
    @cache = ActiveSupport::Cache::MemoryStore.new
    @original_cache = Rails.cache
    Rails.cache = @cache
  end

  teardown do
    Rails.cache = @original_cache
  end

  test "maybe_send pushes message on the 25th once per group" do
    client = FakeClient.new

    travel_to ActiveSupport::TimeZone["Tokyo"].local(2026, 3, 25, 9, 0, 0) do
      RentAndUtilitiesReminder.maybe_send(group_id: "G456", client:)
      RentAndUtilitiesReminder.maybe_send(group_id: "G456", client:)
    end

    assert_equal 1, client.requests.size
    assert_equal "G456", client.requests.first.to
    assert_equal "家賃, 光熱費を教えてくれ！", client.requests.first.messages.first.text
  end

  test "maybe_send skips on non-25th days" do
    client = FakeClient.new

    travel_to ActiveSupport::TimeZone["Tokyo"].local(2026, 3, 24, 9, 0, 0) do
      RentAndUtilitiesReminder.maybe_send(group_id: "G456", client:)
    end

    assert_empty client.requests
  end

  test "maybe_send skips without group_id" do
    client = FakeClient.new

    travel_to ActiveSupport::TimeZone["Tokyo"].local(2026, 3, 25, 9, 0, 0) do
      RentAndUtilitiesReminder.maybe_send(group_id: nil, client:)
    end

    assert_empty client.requests
  end
end
