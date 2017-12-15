# frozen_string_literal: true

module Decidim
  module Proposals
    require "wicked"
    # Exposes the proposal wizard so users can create them step by step.
    class ProposalWizardController < Decidim::Proposals::ApplicationController
      helper Decidim::WidgetUrlsHelper
      include Wicked::Wizard
      include Decidim::FormFactory

      steps :step_1,
            :step_2,
            :step_3,
            :step_4,
            :step_5

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
        session[:proposal] = {}
        redirect_to proposals_path
      end

      private

      def step_1_step
        session[:proposal] ||= {}
        @form = form(Decidim::Proposals::ProposalForm).instance
        render_wizard
      end

      def step_2_step
        @form = form(Decidim::Proposals::ProposalForm).from_params(params)
        session[:proposal] = params[:proposal]
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
        session[:proposal] = params[:proposal] if params[:proposal].present?
        @form = form(Decidim::Proposals::ProposalForm).from_params(
          attachment: form(Decidim::AttachmentForm).from_params({})
        )
        render_wizard
      end

      def step_4_step
        session[:proposal] = params[:proposal]
        @form = form(Decidim::Proposals::ProposalForm).from_params(params)
        # TODO: attachments
        if @form.valid?
          render_wizard
        else
          flash.now[:alert] = I18n.t("proposals.proposal_wizard.validation_errors", scope: "decidim")
          flash.now[:alert] += @form.errors.full_messages.to_sentence.downcase
          @step = :step_3
          render "step_3"
        end
      end

      def step_5_step
        # @form = form(Decidim::Proposals::ProposalForm).from_params(
        #   attachment: form(Decidim::AttachmentForm).from_params({})
        # )
        @form = form(Decidim::Proposals::ProposalForm).from_params(params)

        Decidim::Proposals::CreateProposal.call(@form, current_user) do
          on(:ok) do |proposal|
            flash[:notice] = I18n.t("proposals.create.success", scope: "decidim")
            redirect_to proposal_path(proposal)
          end
          on(:invalid) do
            flash.now[:alert] = I18n.t("proposals.create.error", scope: "decidim")
            @step = :step_4
            render "step_4"
          end
        end
      end
    end
  end
end
