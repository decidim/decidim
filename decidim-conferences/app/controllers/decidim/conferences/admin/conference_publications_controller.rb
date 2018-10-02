# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # Controller that allows managing conference publications.
      #
      class ConferencePublicationsController < Decidim::Conferences::Admin::ApplicationController
        include Concerns::ConferenceAdmin

        def create
          enforce_permission_to :publish, :conference, conference: current_conference

          PublishConference.call(current_conference, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("conference_publications.create.success", scope: "decidim.admin")
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("conference_publications.create.error", scope: "decidim.admin")
            end

            redirect_back(fallback_location: conferences_path)
          end
        end

        def destroy
          enforce_permission_to :publish, :conference, conference: current_conference

          UnpublishConference.call(current_conference, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("conference_publications.destroy.success", scope: "decidim.admin")
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("conference_publications.destroy.error", scope: "decidim.admin")
            end

            redirect_back(fallback_location: conferences_path)
          end
        end
      end
    end
  end
end
