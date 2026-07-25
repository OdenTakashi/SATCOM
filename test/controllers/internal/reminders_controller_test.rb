# frozen_string_literal: true

require "test_helper"

class Internal::RemindersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @original_secret = ENV["CRON_SECRET"]
    ENV["CRON_SECRET"] = "test-secret"
  end

  teardown do
    if @original_secret
      ENV["CRON_SECRET"] = @original_secret
    else
      ENV.delete("CRON_SECRET")
    end
  end

  test "returns unauthorized without token" do
    post internal_reminders_rent_and_utilities_path
    assert_response :unauthorized
  end

  test "returns unauthorized with wrong token" do
    post internal_reminders_rent_and_utilities_path, headers: { "Authorization" => "Bearer wrong" }
    assert_response :unauthorized
  end

  test "returns sent count with valid token" do
    travel_to ActiveSupport::TimeZone["Tokyo"].local(2026, 3, 24, 9, 0, 0) do
      post internal_reminders_rent_and_utilities_path, headers: { "Authorization" => "Bearer test-secret" }
    end

    assert_response :success
    assert_equal({ "sent_count" => 0 }, response.parsed_body)
  end
end
