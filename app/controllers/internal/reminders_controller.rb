# frozen_string_literal: true

module Internal
  class RemindersController < ActionController::API
    before_action :authenticate_cron!

    def rent_and_utilities
      sent_count = RentAndUtilitiesReminder.call
      render json: { sent_count: }
    end

    private

    def authenticate_cron!
      provided = request.headers["Authorization"]&.delete_prefix("Bearer ")
      expected = ENV["CRON_SECRET"].to_s

      head :unauthorized unless provided.present? && expected.present? &&
        ActiveSupport::SecurityUtils.secure_compare(provided, expected)
    end
  end
end
