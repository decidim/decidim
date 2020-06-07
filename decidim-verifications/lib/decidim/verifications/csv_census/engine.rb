# frozen_string_literal: true

module Decidim
  module Verifications
    module CsvCensus
      class Engine < ::Rails::Engine
        isolate_namespace Decidim::Verifications::CsvCensus

        paths["db/migrate"] = nil
        paths["lib/tasks"] = nil

        routes do
          resource :authorization, only: [:new], as: :authorization do
            get :renew, on: :collection
          end
          root to: "authorizations#new"
        end
      end
    end
  end
end
