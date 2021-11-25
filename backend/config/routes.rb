Rails.application.routes.draw do

  namespace :api do
    namespace :v1 do
      get '/my_profile', to: 'users#my_profile'
    end
  end

  match '*unmatched', to: 'application#route_not_found', via: :all
end
