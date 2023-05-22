# frozen_string_literal: true

module Decidim
  module Verifications
    module Sms
      # This is an engine that authorizes users by sending them a code through an SMS.
      class Engine < ::Rails::Engine
        isolate_namespace Decidim::Verifications::Sms

        paths["db/migrate"] = nil
        paths["lib/tasks"] = nil

        routes do
          resource :authorizations, only: [:new, :create, :edit, :update, :destroy], as: :authorization do
            get :renew, on: :collection
          end

          root to: "authorizations#new"
        end

        initializer "decidim_verifications_sms.workflow" do |_app|
          if Decidim.sms_gateway_service
            Decidim::Verifications.register_workflow(:sms) do |workflow|
              workflow.engine = Decidim::Verifications::Sms::Engine
              workflow.icon = "message-3-line"
            end
          end
        end
      end
    end
  end
end
