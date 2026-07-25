# frozen_string_literal: true

namespace :reminder do
  desc "Send rent and utilities reminder to LINE groups (set FORCE=1 to run on non-25th days)"
  task rent_and_utilities: :environment do
    sent_count = RentAndUtilitiesReminder.call(force: ENV["FORCE"] == "1")
    puts "Sent #{sent_count} reminder(s)."
  end
end
