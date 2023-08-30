Rails.application.routes.draw do
  namespace :api do
    namespace :v0 do
      resources :markets, only: %i[index show] do
        resources :vendors, controller: 'market_vendors', only: [:index]
      end
      resources :vendors, only: %i[index show create update destroy]

      # Explicitly adding destroy route for market_vendors
      delete 'market_vendors', to: 'market_vendors#destroy'

      resources :market_vendors, only: %i[create]
    end
  end
end
