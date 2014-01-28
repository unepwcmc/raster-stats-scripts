DashboardExample::Application.routes.draw do
  get "dashboard/index"
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'dashboard#index'

  #namespace :api do
  #  resources :stats, :only => [:index, :show]
  #end
  
end
