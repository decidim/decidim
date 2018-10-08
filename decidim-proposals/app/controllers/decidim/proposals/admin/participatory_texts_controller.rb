# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # This controller manages the participatory texts area.
      class ParticipatoryTextsController < Admin::ApplicationController
        helper_method :proposal
        helper ParticipatoryTextsHelper

        def index
          @drafts = Proposal.where(component: current_component).drafts.order(:position)
          @preview_form = form(Admin::PreviewParticipatoryTextForm).instance
          @preview_form.from_models(@drafts)
        end

        def new_import
          enforce_permission_to :import, :participatory_texts
          @import = form(Admin::ImportParticipatoryTextForm).instance
        end

        def import
          enforce_permission_to :import, :participatory_texts
          @import = form(Admin::ImportParticipatoryTextForm).from_params(params)

          Admin::ImportParticipatoryText.call(@import) do
            on(:ok) do
              flash[:notice] = I18n.t("participatory_texts.import.success", scope: "decidim.proposals.admin")
              redirect_to participatory_texts_path(component_id: current_component.id, initiative_slug: "asdf")
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("participatory_texts.import.invalid", scope: "decidim.proposals.admin")
              render action: "new_import"
            end
          end
        end

        def publish
          enforce_permission_to :publish, :participatory_texts
          form_params = params.require(:preview_participatory_text).permit!
          @preview_form = form(Admin::PreviewParticipatoryTextForm).from_params(proposals: form_params[:proposals_attributes]&.values)

          PublishParticipatoryText.call(@preview_form) do
            on(:ok) do
              flash[:notice] = I18n.t("participatory_texts.publish.success", scope: "decidim.proposals.admin")
              redirect_to proposals_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("participatory_texts.publish.invalid", scope: "decidim.proposals.admin")
              index
              render action: "index"
            end
          end
        end
      end
    end
  end
end
