Rails.application.routes.draw do
  if Rails.env.development?
    mount Rswag::Ui::Engine => '/api-docs'
    mount Rswag::Api::Engine => '/api-docs'
  end

  get '/service/:service_slug/user/:user_id', to: 'user_data#show'
  post '/service/:service_slug/user/:user_id', to: 'user_data#create_or_update'

  post '/service/:service_slug/savereturn/setup/email/add', to: 'emails#add'
  post '/service/:service_slug/savereturn/setup/email/validate', to: 'emails#validate'

  post '/service/:service_slug/savereturn/setup/mobile/add', to: 'mobiles#add'
  post '/service/:service_slug/savereturn/setup/mobile/validate', to: 'mobiles#validate'

  post '/service/:service_slug/savereturn/record/create', to: 'save_returns#create'
  delete '/service/:service_slug/savereturn/record/delete', to: 'save_returns#delete'

  post '/service/:service_slug/savereturn/signin/email/add', to: 'email_signins#add'
  post '/service/:service_slug/savereturn/signin/email/validate', to: 'email_signins#validate'

  post '/service/:service_slug/savereturn/signin/mobile/add', to: 'mobile_signins#add'
  post '/service/:service_slug/savereturn/signin/mobile/validate', to: 'mobile_signins#validate'
end
