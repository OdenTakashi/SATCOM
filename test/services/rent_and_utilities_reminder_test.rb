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
      true
    end
  end

  test "call sends message on the 25th" do
    Payment.create!(line_user_id: "U123", group_id: "G456", amount: 500)
    client = FakeClient.new

    travel_to ActiveSupport::TimeZone["Tokyo"].local(2026, 3, 25, 9, 0, 0) do
      assert_equal 1, RentAndUtilitiesReminder.call(client:)
    end

    assert_equal 1, client.requests.size
    assert_equal "G456", client.requests.first.to
    assert_equal "家賃, 光熱費を教えてくれ！", client.requests.first.messages.first.text
  end

  test "call skips on non-25th days" do
    Payment.create!(line_user_id: "U123", group_id: "G456", amount: 500)

    travel_to ActiveSupport::TimeZone["Tokyo"].local(2026, 3, 24, 9, 0, 0) do
      assert_equal 0, RentAndUtilitiesReminder.call(client: FakeClient.new)
    end
  end

  test "call runs on non-25th days when forced" do
    Payment.create!(line_user_id: "U123", group_id: "G456", amount: 500)
    client = FakeClient.new

    travel_to ActiveSupport::TimeZone["Tokyo"].local(2026, 3, 24, 9, 0, 0) do
      assert_equal 1, RentAndUtilitiesReminder.call(force: true, client:)
    end

    assert_equal "G456", client.requests.first.to
  end

  test "call uses LINE_GROUP_ID when no payments exist" do
    ENV["LINE_GROUP_ID"] = "G999"
    client = FakeClient.new

    travel_to ActiveSupport::TimeZone["Tokyo"].local(2026, 3, 25, 9, 0, 0) do
      assert_equal 1, RentAndUtilitiesReminder.call(client:)
    end

    assert_equal "G999", client.requests.first.to
  ensure
    ENV.delete("LINE_GROUP_ID")
  end
end
