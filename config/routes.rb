Rails.application.routes.draw do

	devise_for :users
	root :to => 'pages#home'

	resources :users do
		collection do
			get 'retired'
		end
	end
	resources :organizations
	resources :orders do
		member do
			put 'approve'
			put 'deny'
			put 'claim'
			put 'unclaim'
			put 'change_progress'
			put 'subscribe'
			put 'unsubscribe'
		end
		collection do
			get 'completed'
		end
	end
	resources :assignments
	resources :comments
	resources :notifications, only: [:index, :destroy] do
		member do
			put 'read'
		end
	end
end