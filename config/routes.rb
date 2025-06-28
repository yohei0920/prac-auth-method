Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api do
    namespace :v1 do
      # 認証関連のルート
      post 'auth/login', to: 'auth#login'
      post 'auth/refresh', to: 'auth#refresh'
      post 'auth/logout', to: 'auth#logout'
      
      # JWT認証関連のルート
      post 'auth/jwt_login', to: 'auth#jwt_login'
      post 'auth/jwt_refresh', to: 'auth#jwt_refresh'
      post 'auth/jwt_logout', to: 'auth#jwt_logout'
      
      # 既存のヘルスチェックルート
      get 'health', to: 'health#index'
      post 'health', to: 'health#create'
      put 'health', to: 'health#update'
      delete 'health', to: 'health#destroy'
    end
  end
end
