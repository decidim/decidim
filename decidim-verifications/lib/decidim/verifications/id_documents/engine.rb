# frozen_string_literal: true

module Decidim
  module Verifications
    module IdDocuments
      # This is an engine that performs an example user authorization.
      class Engine < ::Rails::Engine
        isolate_namespace Decidim::Verifications::IdDocuments

        routes do
          resource :authorizations, only: [:new, :create, :edit], as: :authorization

          root to: "authorizations#new"
        end
      end
    end
  end
end
