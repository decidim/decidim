# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # This controller manages the participatory texts area.
      class ParticipatoryTextsController < Admin::ApplicationController
        helper_method :proposal

        def index
          # enforce_permission_to :create, :proposal_answer
          # @form = form(Admin::ProposalAnswerForm).from_model(proposal)
        end

        def new_import
          @import = form(Admin::ImportParticipatoryTextForm).instance
        end

        def import
          enforce_permission_to :import, :participatory_texts
          @import = form(Admin::ImportParticipatoryTextForm).instance

          Admin::ImportParticipatoryText.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("participatory_texts.import.success", scope: "decidim.proposals.admin")
              redirect_to proposals_path
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
