# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # Controller that allows managing consultation result publications.
      class ConsultationResultsPublicationsController < Decidim::Consultations::Admin::ApplicationController
        include ConsultationAdmin

        def create
          enforce_permission_to :publish_results, :consultation, consultation: current_consultation

          PublishConsultationResults.call(current_consultation) do
            on(:ok) do
              flash[:notice] = I18n.t("consultation_results_publications.create.success", scope: "decidim.admin")
            end

            on(:invalid) do
              flash[:alert] = I18n.t("consultation_results_publications.create.error", scope: "decidim.admin")
            end

            redirect_back(fallback_location: consultations_path)
          end
        end

        def destroy
          enforce_permission_to :unpublish_results, :consultation, consultation: current_consultation

          UnpublishConsultationResults.call(current_consultation) do
            on(:ok) do
              flash[:notice] = I18n.t("consultation_results_publications.destroy.success", scope: "decidim.admin")
            end

            on(:invalid) do
              flash[:alert] = I18n.t("consultation_results_publications.destroy.error", scope: "decidim.admin")
            end

            redirect_back(fallback_location: consultations_path)
          end
        end
      end
    end
  end
end
