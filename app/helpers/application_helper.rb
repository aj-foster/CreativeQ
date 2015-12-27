module ApplicationHelper

	def resource_name
		:user
	end

	def resource
		@resource ||= User.new
	end

	def devise_mapping
		@devise_mapping ||= Devise.mappings[:user]
	end

	def tooltip(title)
		"data-toggle='tooltip' data-placement='bottom' tabindex='0' title='#{h title}'".html_safe
	end
end