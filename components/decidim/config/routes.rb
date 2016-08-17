Decidim::Engine.routes.draw do
  devise_for :users, class_name: "Decidim::User", module: :devise
  root to: "home#show"
end
