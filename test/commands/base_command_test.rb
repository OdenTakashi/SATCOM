# frozen_string_literal: true

require "test_helper"

class BaseCommandTest < ActiveSupport::TestCase
  test "call raises NotImplementedError" do
    klass = Class.new(BaseCommand)
    klass.const_set(:PATTERN, /\A\/(\d+)\z/)

    assert_raises(NotImplementedError) do
      klass.call(line_user_id: "U123", text: "/500")
    end
  end
end
