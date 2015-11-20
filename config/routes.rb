Rails.application.routes.default_url_options[:host] = 'localhost:3000'

Rails.application.routes.draw do

  # match "/websocket", :to => ActionCable.server, via: [:get, :post]

  get 'worker/status'


  get 'home/index'


  resources :libraries, shallow: true do
    resources :references, except: [:destroy] do
        post :delete, action: :delete, on: :collection
        get :refresh_labels, action: :refresh_labels, on: :collection
    end
    resources :resources do
      post :delete, action: :delete, on: :collection
      post :add_label, action: :add_label, on: :collection
    end
    resources :labels, only: [:create]
    resources :raw_bibtex_entries, except: [:destroy] do
        post :delete, action: :delete, on: :collection
        post :import, action: :import, on: :collection
    end
  end

  post 'libraries/:library_id/raw_bibtex_entries/upload' => 'raw_bibtex_entries#upload', as: :upload_raw_bibtex_entry

  post 'libraries/:library_id/references/add_label/:label_id' => 'references#add_label', as: :add_label_to_reference

  # devise_for :users
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  match 'file_managers/oauth2_callback' => 'file_managers#oauth2_callback', via: [:get, :post], as: :oauth2_callback

  get 'file_managers/new' => 'file_managers#new', as: :new_file_manager

  get 'file_managers/create_oauth2/:type' => 'file_managers#create_oauth2_file_manager', as: :create_oauth2_file_manager

  # get 'libraries/index'
  # resources :libraries
  root 'home#index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
