# frozen_string_literal: true

class SummaryCommand < BaseCommand
  DATE_PATTERN = /\d{4}-\d{1,2}-\d{1,2}|\d{1,2}\/\d{1,2}/
  PATTERN = %r{\A/(?:\s+(#{DATE_PATTERN})(?:\s+(?:-|~|〜)\s+|\s+)(#{DATE_PATTERN}))?\z}
  MONTHLY_BUDGET = 30_000

  def call
    payments = Payment.where(group_id:, created_at: period_range)

    if payments.empty?
      "まだ記録がないぜ。オーバー!"
    else
      totals = payments.group(:line_user_id).sum(:amount)
      lines = totals.map { |user_id, total| "#{display_name(user_id)}: #{MONTHLY_BUDGET - total}円" }
      "--- 集計 (#{period_label}) ---\n#{lines.join("\n")}\nオーバー!"
    end
  end

  private

  def period_range
    explicit_period? ? period_start...period_end : period_start..
  end

  def period_label
    explicit_period? ? "#{period_start.strftime("%m/%d")}〜#{period_end.strftime("%m/%d")}" : "#{period_start.strftime("%m/%d")}〜"
  end

  def period_start
    @period_start ||= explicit_period? ? parse_date(match_data[1]) : default_period_start
  end

  def period_end
    @period_end ||= parse_date(match_data[2])
  end

  def explicit_period?
    match_data[1].present? && match_data[2].present?
  end

  def default_period_start
    today = Time.current.to_date
    today.day >= 25 ? today.change(day: 25) : today.prev_month.change(day: 25)
  end

  def parse_date(value)
    date =
      if value.include?("/")
        month, day = value.split("/").map(&:to_i)
        Date.new(Time.current.year, month, day)
      else
        Date.iso8601(value)
      end

    Time.zone.local(date.year, date.month, date.day)
  end
end
