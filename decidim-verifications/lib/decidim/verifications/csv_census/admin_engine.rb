# frozen_string_literal: true

module Decidim
  module Verifications
    module CsvCensus
      class AdminEngine < ::Rails::Engine
        isolate_namespace Decidim::Verifications::CsvCensus::Admin

        paths["db/migrate"] = nil
        paths["lib/tasks"] = nil

        routes do
          resources :census_logs, only: [:index, :destroy], controller: "census" do
            member do
              get :edit_record, controller: "census_records"
              patch :update_record, controller: "census_records"
            end
            collection do
              get :new_import
              post :create_import
              get :new_record, controller: "census_records"
              post :create_record, controller: "census_records"
            end
          end

          root to: "census#index"
        end
      end
    end
  end
end
