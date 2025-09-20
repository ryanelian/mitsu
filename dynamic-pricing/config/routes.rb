Rails.application.routes.draw do
  get '/pricing', to: 'pricing#index'
  get '/healthz', to: 'healthz#index'
end
