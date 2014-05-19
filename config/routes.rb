Rails.application.routes.draw do

	devise_for :users
	root :to => 'pages#home'

	resources :users
	resources :organizations
	resources :orders do
		member do
			put 'approve'
			put 'deny'
			put 'claim'
			put 'unclaim'
			put 'change_status'
		end
	end
end