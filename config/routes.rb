# == Route Map
#
#             Prefix Verb   URI Pattern                      Controller#Action
#        new_session GET    /session/new(.:format)           sessions#new
#       edit_session GET    /session/edit(.:format)          sessions#edit
#            session GET    /session(.:format)               sessions#show
#                    PATCH  /session(.:format)               sessions#update
#                    PUT    /session(.:format)               sessions#update
#                    DELETE /session(.:format)               sessions#destroy
#                    POST   /session(.:format)               sessions#create
#          passwords GET    /passwords(.:format)             passwords#index
#                    POST   /passwords(.:format)             passwords#create
#       new_password GET    /passwords/new(.:format)         passwords#new
#      edit_password GET    /passwords/:token/edit(.:format) passwords#edit
#           password GET    /passwords/:token(.:format)      passwords#show
#                    PATCH  /passwords/:token(.:format)      passwords#update
#                    PUT    /passwords/:token(.:format)      passwords#update
#                    DELETE /passwords/:token(.:format)      passwords#destroy
# rails_health_check GET    /up(.:format)                    rails/health#show

Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  get "up" => "rails/health#show", as: :rails_health_check
end
