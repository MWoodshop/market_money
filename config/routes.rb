Rails.application.routes.draw do
  get '/ping', to: 'application#ping'

  namespace :api do
    namespace :v0 do
      resources :markets, only: %i[index show] do
        collection do
          get 'search'
        end
        resources :vendors, controller: 'market_vendors', only: [:index]
        get 'nearest_atms', to: 'cash_dispensers#nearest'
      end
      resources :vendors, only: %i[index show create update destroy]

      # Explicitly adding destroy route for market_vendors
      delete 'market_vendors', to: 'market_vendors#destroy'
      resources :market_vendors, only: %i[create]
    end
  end
end
