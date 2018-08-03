# frozen_string_literal: true

Decidim::Api::Engine.routes.draw do
  mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/api", as: :graphiql
  get "/docs", to: "documentation#show", as: :documentation
  get "/", to: redirect("/api/docs")
  post "/" => "queries#create", as: :root
end
