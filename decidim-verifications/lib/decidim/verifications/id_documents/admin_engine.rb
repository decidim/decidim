# frozen_string_literal: true

module Decidim
  module Verifications
    module IdDocuments
      # This is an engine that performs an example user authorization.
      class AdminEngine < ::Rails::Engine
        isolate_namespace Decidim::Verifications::IdDocuments::Admin

        routes do
          resources :pending_authorizations, only: :index do
            resource :confirmations, only: [:new, :create], as: :confirmation
            resource :rejections, only: :create, as: :rejection
          end

          root to: "pending_authorizations#index"
        end
      end
    end
  end
end
