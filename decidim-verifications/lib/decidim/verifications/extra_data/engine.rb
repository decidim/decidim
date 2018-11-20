# frozen_string_literal: true

module Decidim
  module Verifications
    module ExtraData
      class Engine < ::Rails::Engine
        isolate_namespace Decidim::Verifications::ExtraData

        paths["db/migrate"] = nil
        paths["lib/tasks"] = nil

        routes do
          resource :authorizations, only: [:new, :create, :edit, :update], as: :authorization

          root to: "authorizations#new"
        end
      end
    end
  end
end
