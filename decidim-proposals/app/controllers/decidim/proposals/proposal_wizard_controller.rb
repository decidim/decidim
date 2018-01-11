# frozen_string_literal: true

module Decidim
  module Proposals
    require "wicked"
    # Exposes the proposal wizard so users can create them step by step.
    class ProposalWizardController < Decidim::Proposals::ApplicationController
      helper Decidim::WidgetUrlsHelper
      include Wicked::Wizard
      include Decidim::FormFactory

      before_action :current_proposal

      steps :step_1,
            :step_2,
            :step_3,
            :step_create,
            :step_4,
            :step_publish,

      def show
        @step = step
        authorize! :create, Proposal
        send("#{step}_step")
      end

      def update
        @step = step
        authorize! :create, Proposal
        send("#{step}_step")
      end

      def exit
        flash[:notice] = I18n.t("proposals.proposal_wizard.exited", scope: "decidim")
        if params[:proposal_id].present?
          redirect_to proposal_path params[:proposal_id]
        else
          redirect_to proposals_path
        end
      end

      private

      def step_1_step
        @form = form(Decidim::Proposals::ProposalForm).instance
        render_wizard
      end

      def step_2_step
        @form = form(Decidim::Proposals::ProposalForm).from_params(params)
        if @form.valid?
          @similar_proposals ||= Decidim::Proposals::SimilarProposals
                                 .for(current_feature, @form)
                                 .all
          render_wizard
        else
          flash.now[:alert] = I18n.t("proposals.proposal_wizard.validation_errors", scope: "decidim")
          flash.now[:alert] += @form.errors.full_messages.to_sentence.downcase
          @step = :step_1
          render "step_1"
        end
      end

      def step_3_step
        if params[:proposal_draft].present?
          @proposal = proposal_draft
          @form = form(Decidim::Proposals::ProposalForm).from_model(@proposal)
        else
          @form = form(Decidim::Proposals::ProposalForm).from_params(
            params.merge(
              attachment: form(Decidim::AttachmentForm).from_params({})
            )
          )
        end
        render_wizard
      end

      def step_create_step
        @form = form(Decidim::Proposals::ProposalForm).from_params(params)

        @proposal.destroy if @proposal

        Decidim::Proposals::CreateProposal.call(@form, current_user) do
          on(:ok) do |proposal|
            flash.now[:notice] = I18n.t("proposals.proposal_wizard.draft_created", scope: "decidim")
            redirect_to wizard_path(:step_4)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("proposals.create.error", scope: "decidim")
            @step = :step_3
            render "step_3"
          end
        end
      end

      def step_4_step
        @form = form(Decidim::Proposals::ProposalForm).from_model(@proposal)
      end

      def step_publish_step
        @proposal.published_at = Time.zone.now

        if @proposal.save
          flash.now[:notice] = I18n.t("proposals.proposal_wizard.published", scope: "decidim")
          redirect_to proposal_path(@proposal)
        else
          flash.now[:alert] = I18n.t("proposals.create.error", scope: "decidim")
          @step = :step_3
          render "step_3"
        end
      end

      def current_proposal
        @proposal = proposal_draft
      end

      def proposal_draft
        Decidim::Proposals::Proposal.where(decidim_author_id: current_user, feature: current_feature).find_by(published_at: nil)
      end
    end
  end
end
