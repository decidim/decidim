# frozen_string_literal: true

module Decidim
  module Verifications
    # Decidim's core Rails Engine.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Verifications

      routes do
        authenticate(:user) do
          resources :authorizations, only: [:new, :create, :index] do
            collection do
              get :first_login
            end
          end

          Decidim::Verifications.workflows.each do |manifest|
            mount manifest.engine, at: "/#{manifest.name}", as: "decidim_#{manifest.name}"
          end
        end
      end
    end
  end
end
