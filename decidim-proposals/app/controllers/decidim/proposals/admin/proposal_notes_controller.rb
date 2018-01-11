# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # This controller allows admins to answer proposals in a participatory process.
      class ProposalNotesController < Admin::ApplicationController
        helper_method :proposal

        def index
          # authorize! :create, ProposalNote
          @form = form(ProposalNoteForm).instance
        end

        def create
          # authorize! :create, ProposalNote
          @form = form(ProposalNoteForm).from_params(params.merge(proposal: proposal, current_user: current_user))

          CreateNoteProposal.call(@form, proposal, current_user ) do
            on(:ok) do |note|
              flash[:notice] = I18n.t("proposals.create.success", scope: "decidim")
              redirect_to proposal_proposal_notes_path(proposal_id: proposal.id)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("proposals.create.error", scope: "decidim")
              render :index
            end
          end
        end

        private

        def proposal
          @proposals ||= Proposal.where(feature: current_feature).find(params[:proposal_id])
        end
      end
    end
  end
end
