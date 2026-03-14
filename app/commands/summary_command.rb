# frozen_string_literal: true

class SummaryCommand < BaseCommand
  PATTERN = /\A\/\z/
  MONTHLY_BUDGET = 30_000

  def call
    payments = Payment.where(group_id:, created_at: period_start..)

    if payments.empty?
      "まだ記録がないぜ。オーバー!"
    else
      totals = payments.group(:line_user_id).sum(:amount)
      lines = totals.map { |user_id, total| "#{display_name(user_id)}: #{MONTHLY_BUDGET - total}円" }
      "--- 集計 (#{period_start.strftime("%m/%d")}〜) ---\n#{lines.join("\n")}\nオーバー!"
    end
  end

  private

  def period_start
    @period_start ||= begin
      today = Time.current.to_date
      today.day >= 25 ? today.change(day: 25) : today.prev_month.change(day: 25)
    end
  end
end
