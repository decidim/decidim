# frozen_string_literal: true

module Decidim
  module Proposals
    require 'wicked'
    # Exposes the proposal wizard so users can create them step by step.
    class ProposalWizardController < Decidim::Proposals::ApplicationController
      helper Decidim::WidgetUrlsHelper
      include Wicked::Wizard
      include Decidim::FormFactory

      helper_method :current_proposal

      steps :step_1,
            :step_2,
            :step_3,
            :step_4,
            :step_5

      def show
        authorize! :create, Proposal
        @step = step
        case step
        when :step_1
          step_1_step
        when :step_5
          step_5_step params
        else
          @form = build_form(Decidim::Proposals::ProposalWizardForm, params)
          render_wizard
        end
        # unless @form.valid?
        #   raise
        #   redirect_to previous_wizard_path(validate_form: true)
        # else
        #  render_wizard
        # end
      end

      def update
        @step = step
        authorize! :create, Proposal
        case step
        when :step_1
          step_1_step
        when :step_5
          step_5_step params
        else
          @form = build_form(Decidim::Proposals::ProposalWizardForm, params)
          render_wizard
        end

      end

      def create
        @form = Proposal.create
        redirect_to proposal_wizard_path(steps.first, proposal_id: @form.id)
      end

      private
      def step_1_step
        session[:proposal] = {}
        @form = form(Decidim::Proposals::ProposalWizardForm).instance
        # @form = form(ProposalForm).from_params(
        #   attachment: form(AttachmentForm).from_params({})
        # )
        render_wizard
      end

      def step_5_step(params)
        @form = form(Decidim::Proposals::ProposalWizardForm).from_params(params)

        Decidim::Proposals::CreateProposal.call(@form, current_user) do
          on(:ok) do |proposal|
            flash[:notice] = I18n.t("proposals.create.success", scope: "decidim")
            redirect_to proposal_path(proposal)
          end
          on(:invalid) do
            flash.now[:alert] = I18n.t("proposals.create.error", scope: "decidim")
            render :show
          end
        end
      end

      def build_form(klass, parameters)
        @form = form(klass).from_params(parameters,
          # attachment: form(AttachmentForm).from_params({})
        )
        attributes = @form.attributes_with_values
        session[:proposal] = session[:proposal].merge(attributes)
        @form.valid? if params[:validate_form]

        @form
      end

    end
  end
end
