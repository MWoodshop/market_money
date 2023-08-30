Rails.application.routes.draw do
  namespace :api do
    namespace :v0 do
      # Get all markets and get one market
      resources :markets, only: %i[index show] do
        # Get all vendors for a specific market
        resources :vendors, controller: 'market_vendors', only: [:index]
      end
      resources :vendors, only: %i[index show create update destroy]
      resources :market_vendors, only: [:create]
    end
  end
end
