# frozen_string_literal: true

require "test_helper"

class HelpCommandTest < ActiveSupport::TestCase
  test "match? returns true for /h" do
    assert HelpCommand.match?("/h")
  end

  test "match? returns false for non-command text" do
    assert_not HelpCommand.match?("/help")
    assert_not HelpCommand.match?("/H")
    assert_not HelpCommand.match?("h")
    assert_not HelpCommand.match?("/h ")
  end

  test "call returns help text with command list" do
    command = HelpCommand.new(line_user_id: "U123", group_id: "G456", match_data: HelpCommand::PATTERN.match("/h"))
    result = command.call

    assert_includes result, "SATCOMコマンド一覧"
    assert_includes result, "/金額"
    assert_includes result, "/500"
    assert_includes result, "/ … 今月の集計を表示する。"
    assert_includes result, "/h … このヘルプを表示する。"
    assert_includes result, "オーバー。"
  end
end
