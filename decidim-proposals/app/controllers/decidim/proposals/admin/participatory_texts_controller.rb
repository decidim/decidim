# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # This controller manages the participatory texts area.
      class ParticipatoryTextsController < Admin::ApplicationController
        helper_method :proposal

        def index
          @drafts = Proposal.where(component: current_component).drafts
          @preview_form = form(Admin::PreviewParticipatoryTextForm).instance
          # @preview_form.from_models(drafts)
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
              redirect_to participatory_texts_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("participatory_texts.imports.invalid", scope: "decidim.proposals.admin")
              render action: "new_import"
            end
          end
        end
      end
    end
  end
end
