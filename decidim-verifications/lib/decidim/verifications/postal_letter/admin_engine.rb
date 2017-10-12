# frozen_string_literal: true

module Decidim
  module Verifications
    module PostalLetter
      # This is an engine that implements the administration interface for
      # user authorization by postal letter code.
      class AdminEngine < ::Rails::Engine
        isolate_namespace Decidim::Verifications::PostalLetter::Admin

        routes do
          resources :pending_authorizations, only: :index

          root to: "pending_authorizations#index"
        end
      end
    end
  end
end
