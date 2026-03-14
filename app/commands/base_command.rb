# frozen_string_literal: true

class BaseCommand
  class << self
    def match?(text)
      self::PATTERN.match?(text)
    end

    def call(line_user_id:, text:)
      new(line_user_id:, match_data: self::PATTERN.match(text)).call
    end
  end

  def initialize(line_user_id:, match_data:)
    @line_user_id = line_user_id
    @amount = match_data[1].to_i
  end

  def call
    raise NotImplementedError
  end

  private

  attr_reader :line_user_id, :amount
end
