SimpleForum::Engine.routes.draw do

  root :to => 'forums#index', :via => :get

  resources :forums, :only => [:index, :show], :path => 'f' do
    resources :topics, :only => [:index, :show, :new, :create], :path => 't' do
      member do
        post :open
        post :close
      end

      resources :posts, :except => [:destroy], :path => 'p' do
        delete :delete, :on => :member
        get :preview, :on => :collection
      end
    end
    collection do
      get :search
    end
  end

  namespace :admin do
    resources :forums do
      get :search_users, :on => :collection
      resources :topics, :only => [:destroy]
    end
    resources :categories

  end

end