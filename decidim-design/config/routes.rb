Rails.application.routes.draw do
  get HighVoltage.route_drawer.match_attributes

  get "/#{HighVoltage.home_page}", to: redirect('/')
  root to: 'high_voltage/pages#show', id: HighVoltage.home_page
end
