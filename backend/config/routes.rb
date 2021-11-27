Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get '/my_profile', to: 'users#my_profile'

      resources :foods, only: [:create, :index]

      namespace :admin do
        resources :foods, only: [:update, :index, :destroy] do
          collection do
            get 'user_statistics', to: 'foods#user_statistics'
            get 'global_statistics', to: 'foods#global_statistics'
          end
        end
      end
    end
  end

  match '*unmatched', to: 'application#route_not_found', via: :all
end
