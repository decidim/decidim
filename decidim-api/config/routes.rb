# frozen_string_literal: true

Decidim::Api::Engine.routes.draw do
  get "/graphiql", to: "graphiql#show", graphql_path: "/api", as: :graphiql
  get "/docs", to: "documentation#show", as: :documentation
  get "/docs/*path", to: "documentation#show"
  get "/", to: redirect("/api/docs")
  post "/" => "queries#create", as: :root
end
