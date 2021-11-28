Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do

      get '/users/my_profile'

      resources :foods, only: [:create, :index] do
        collection do
          get 'daily_statistics'
        end
      end

      namespace :admin do
        resources :foods, only: [:update, :index, :destroy] do
          collection do
            get 'user_statistics'
            get 'global_statistics'
          end
        end
      end
    end
  end

  match '*unmatched', to: 'application#route_not_found', via: :all
end
