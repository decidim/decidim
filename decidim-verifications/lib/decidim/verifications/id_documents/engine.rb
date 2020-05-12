# frozen_string_literal: true

module Decidim
  module Verifications
    module IdDocuments
      # This is an engine that performs an example user authorization.
      class Engine < ::Rails::Engine
        isolate_namespace Decidim::Verifications::IdDocuments

        paths["db/migrate"] = nil
        paths["lib/tasks"] = nil

        routes do
          resource :authorizations, only: [:new, :create, :edit, :update], as: :authorization do
            collection do
              get :choose
              get :renew
            end
          end

          root to: "authorizations#choose"
        end
      end
    end
  end
end
