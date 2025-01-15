# frozen_string_literal: true

module Decidim
  module Verifications
    module CsvCensus
      class AdminEngine < ::Rails::Engine
        isolate_namespace Decidim::Verifications::CsvCensus::Admin

        paths["db/migrate"] = nil
        paths["lib/tasks"] = nil

        routes do
          resources :census, except: [:show] do
            collection do
              get :new_import
              delete :destroy_all
              post :create_import
            end
          end

          root to: "census#index"
        end
      end
    end
  end
end
