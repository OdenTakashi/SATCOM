# frozen_string_literal: true

class RecordPaymentCommand < BaseCommand
  PATTERN = /\A\/(\d+)\z/

  def call
    if Payment.new(line_user_id:, group_id:, amount:).save
      "#{amount}円の立替、記録したぜ。オーバー!"
    else
      "記録に失敗した…もう一度試してくれ。オーバー!"
    end
  end

  private

  def amount
    @amount ||= match_data[1].to_i
  end
end
