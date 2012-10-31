Events::Application.routes.draw do

  root :to => "events#index"
  match "events/:id/tag" => "events#remove_tag", via: :delete
  match "events/add_tag" => "events#add_tag", via: :post
  match "events/local_events" => "events#local_events", via: :get
  match "events/:id/edit" => "events#edit", via: :get
  match "events/my_events" => "events#my_events", via: :get
  match "events/:id/owner" => "events#add_owner", via: :post
  match "events/:id/owner" => "events#remove_owner", via: :delete
  match "events/:id/infowindow" => "events#infowindow", via: :get
  match "events/:id/attend" => "events#attend", via: :post
  match "events/:id/attend" => "events#unattend", via: :delete
  match "events/search" => "events#search", via: :get
  match "events/all_events" => "events#all_events", via: :get
  match "events/past_events" => "events#past_events", via: :get
  match "events/present_events" => "events#present_events", via: :get
  match "events/future_events" => "events#future_events", via: :get
  resources :events, only: [:create, :update, :destroy]

  devise_for :users, controllers: {omniauth_callbacks: "users/omniauth_callbacks"}

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
