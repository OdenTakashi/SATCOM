# frozen_string_literal: true

require "test_helper"

class SummaryCommandTest < ActiveSupport::TestCase
  test "match? returns true for /" do
    assert SummaryCommand.match?("/")
  end

  test "match? returns false for non-command text" do
    assert_not SummaryCommand.match?("summary")
    assert_not SummaryCommand.match?("/ ")
    assert_not SummaryCommand.match?("/500")
  end

  test "call returns empty message when no payments exist" do
    result = build_command.call
    assert_equal "まだ記録がないぜ。オーバー!", result
  end

  test "call returns summary with display names and budget minus amount" do
    travel_to Time.zone.local(2026, 3, 14) do
      Payment.create!(line_user_id: "U123", group_id: "G456", amount: 500, created_at: Time.zone.local(2026, 3, 1))
      Payment.create!(line_user_id: "U123", group_id: "G456", amount: 300, created_at: Time.zone.local(2026, 3, 5))
      Payment.create!(line_user_id: "U789", group_id: "G456", amount: 1000, created_at: Time.zone.local(2026, 3, 1))

      result = build_command(names: { "U123" => "たかし", "U789" => "はなこ" }).call

      assert_includes result, "集計"
      assert_includes result, "たかし: 29200円"
      assert_includes result, "はなこ: 29000円"
      assert_includes result, "オーバー!"
    end
  end

  test "call excludes payments before the 25th period start" do
    travel_to Time.zone.local(2026, 3, 14) do
      Payment.create!(line_user_id: "U123", group_id: "G456", amount: 500, created_at: Time.zone.local(2026, 2, 25))
      Payment.create!(line_user_id: "U123", group_id: "G456", amount: 9999, created_at: Time.zone.local(2026, 2, 24))

      result = build_command.call

      assert_includes result, "U123: 29500円"
      assert_not_includes result, "9999"
    end
  end

  test "period starts on current month 25th when today is after 25th" do
    travel_to Time.zone.local(2026, 3, 27) do
      Payment.create!(line_user_id: "U123", group_id: "G456", amount: 200, created_at: Time.zone.local(2026, 3, 26))
      Payment.create!(line_user_id: "U123", group_id: "G456", amount: 7777, created_at: Time.zone.local(2026, 3, 24))

      result = build_command.call

      assert_includes result, "U123: 29800円"
      assert_not_includes result, "7777"
    end
  end

  private

  def build_command(names: {})
    command = SummaryCommand.new(line_user_id: "U123", group_id: "G456", match_data: SummaryCommand::PATTERN.match("/"))
    if names.any?
      command.define_singleton_method(:display_name) { |uid| names.fetch(uid, uid) }
    else
      command.define_singleton_method(:display_name) { |uid| uid }
    end
    command
  end
end
