# frozen_string_literal: true

Decidim::Api::Engine.routes.draw do
  get "/graphiql", to: "graphiql#show", graphql_path: "/api", as: :graphiql
  get "/docs", to: "documentation#show", as: :documentation
  get "/docs/*path", to: "documentation#show"
  get "/", to: redirect("/api/docs")
  post "/" => "queries#create", :as => :root

  devise_for :api_users,
             class_name: "Decidim::Api::ApiUser",
             module: "decidim/api",
             path: "/",
             router_name: :decidim_api,
             controllers: { sessions: "decidim/api/sessions" },
             only: :sessions
end
