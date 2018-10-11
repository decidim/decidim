# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # Controller that allows managing consultation publications.
      class ConsultationPublicationsController < Decidim::Consultations::Admin::ApplicationController
        include ConsultationAdmin

        def create
          enforce_permission_to :publish, :consultation, consultation: current_consultation

          PublishConsultation.call(current_consultation, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("consultation_publications.create.success", scope: "decidim.admin")
            end

            on(:invalid) do
              flash[:alert] = I18n.t("consultation_publications.create.error", scope: "decidim.admin")
            end

            redirect_back(fallback_location: consultations_path)
          end
        end

        def destroy
          enforce_permission_to :publish, :consultation, consultation: current_consultation

          UnpublishConsultation.call(current_consultation) do
            on(:ok) do
              flash[:notice] = I18n.t("consultation_publications.destroy.success", scope: "decidim.admin")
            end

            on(:invalid) do
              flash[:alert] = I18n.t("consultation_publications.destroy.error", scope: "decidim.admin")
            end

            redirect_back(fallback_location: consultations_path)
          end
        end
      end
    end
  end
end
