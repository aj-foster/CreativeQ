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
			put 'change_status'
		end
		collection do
			get 'completed'
		end
	end
	resources :assignments
end