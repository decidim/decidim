# frozen_string_literal: true

Rails.application.routes.draw do
  scope "/:layout/" do
    get "/*id" => "pages#show", as: :page, format: false

    get "/index", to: redirect("/")
    get "/", to: "pages#show", id: "index"
  end

  root to: "pages#show", id: "index"
end
