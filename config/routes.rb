# == Route Map
#
#             Prefix Verb URI Pattern         Controller#Action
#           callback POST /callback(.:format) webhook#callback
# rails_health_check GET  /up(.:format)       rails/health#show

Rails.application.routes.draw do
  post "/callback" => "webhook#callback"

  namespace :internal do
    post "reminders/rent_and_utilities" => "reminders#rent_and_utilities"
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
