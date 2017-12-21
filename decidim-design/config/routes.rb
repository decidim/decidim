# frozen_string_literal: true

Rails.application.routes.draw do
  get "/*id" => "pages#show", as: :page, format: false

  get "/index", to: redirect("/")
  root to: "pages#show", id: "index"
end
