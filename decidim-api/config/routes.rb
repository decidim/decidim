# frozen_string_literal: true
Decidim::Api::Engine.routes.draw do
  mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/api"
  get "/", to: redirect("/api/graphiql")
  post "/" => "queries#create"
end
