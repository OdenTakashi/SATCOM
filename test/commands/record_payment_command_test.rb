# frozen_string_literal: true

require "test_helper"

class RecordPaymentCommandTest < ActiveSupport::TestCase
  test "match? returns true for /digits" do
    assert RecordPaymentCommand.match?("/500")
    assert RecordPaymentCommand.match?("/1200")
    assert RecordPaymentCommand.match?("/0")
  end

  test "match? returns false for non-command text" do
    assert_not RecordPaymentCommand.match?("hello")
    assert_not RecordPaymentCommand.match?("/abc")
    assert_not RecordPaymentCommand.match?("500")
    assert_not RecordPaymentCommand.match?("/500 ")
  end

  test "call creates a payment and returns success message" do
    assert_difference "Payment.count", 1 do
      result = RecordPaymentCommand.call(line_user_id: "U123", text: "/500")
      assert_equal "500円の立替、記録したぜ。オーバー!", result
    end

    payment = Payment.last
    assert_equal "U123", payment.line_user_id
    assert_equal 500, payment.amount
  end
end
