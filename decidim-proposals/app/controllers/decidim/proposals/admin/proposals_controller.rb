# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # This controller allows admins to manage proposals in a participatory process.
      class ProposalsController < Admin::ApplicationController
        include Decidim::ApplicationHelper
        include Decidim::Admin::ComponentTaxonomiesHelper
        include Decidim::Proposals::Admin::Filterable

        helper Proposals::ApplicationHelper
        helper Decidim::Proposals::Admin::ProposalRankingsHelper
        helper Decidim::Messaging::ConversationHelper
        helper_method :proposals, :query, :form_presenter, :proposal, :proposal_ids
        helper Proposals::Admin::ProposalBulkActionsHelper

        before_action :check_admin_session_filters, only: [:index]

        def index; end

        def show
          @notes_form = form(ProposalNoteForm).instance
          @answer_form = form(Admin::ProposalAnswerForm).from_model(proposal)
        end

        def new
          enforce_permission_to :create, :proposal
          @form = form(Decidim::Proposals::Admin::ProposalForm).from_params(
            attachment: form(AttachmentForm).from_params({})
          )
        end

        def create
          enforce_permission_to :create, :proposal
          @form = form(Decidim::Proposals::Admin::ProposalForm).from_params(params)

          Admin::CreateProposal.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("proposals.create.success", scope: "decidim.proposals.admin")
              redirect_to proposals_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("proposals.create.invalid", scope: "decidim.proposals.admin")
              render action: "new"
            end
          end
        end

        def update_taxonomies
          enforce_permission_to :update, :proposal_taxonomy

          Admin::UpdateProposalTaxonomies.call(params[:taxonomies], proposal_ids, current_organization) do
            on(:invalid_taxonomy) do
              flash[:error] = I18n.t(
                "proposals.update_taxonomies.select_a_taxonomy",
                scope: "decidim.proposals.admin"
              )
            end

            on(:invalid_proposal_ids) do
              flash[:alert] = I18n.t(
                "proposals.update_taxonomies.select_a_proposal",
                scope: "decidim.proposals.admin"
              )
            end

            on(:update_resources_taxonomies) do |response|
              if response[:successful].any?
                flash[:notice] = t(
                  "proposals.update_taxonomies.success",
                  taxonomies: response[:taxonomies].map { |taxonomy| translated_attribute(taxonomy.name) }.to_sentence,
                  proposals: response[:successful].map { |resource| translated_attribute(resource.title) }.to_sentence,
                  scope: "decidim.proposals.admin"
                )
              end
              if response[:errored].any?
                flash[:alert] = t(
                  "proposals.update_taxonomies.invalid",
                  taxonomies: response[:taxonomies].map { |taxonomy| translated_attribute(taxonomy.name) }.to_sentence,
                  proposals: response[:errored].map { |resource| translated_attribute(resource.title) }.to_sentence,
                  scope: "decidim.proposals.admin"
                )
              end
            end
          end

          redirect_to proposals_path
        end

        def publish_answers
          enforce_permission_to :publish_answers, :proposals

          Decidim::Proposals::Admin::PublishAnswers.call(current_component, current_user, proposal_ids) do
            on(:invalid) do
              flash.now[:alert] = t(
                "proposals.publish_answers.select_a_proposal",
                scope: "decidim.proposals.admin"
              )
            end

            on(:ok) do
              flash.now[:notice] = I18n.t("proposals.publish_answers.success", scope: "decidim")
            end
          end

          respond_to do |format|
            format.js
          end
        end

        def edit
          enforce_permission_to(:edit, :proposal, proposal:)
          @form = form(Admin::ProposalForm).from_model(proposal)
        end

        def update
          enforce_permission_to(:edit, :proposal, proposal:)

          @form = form(Admin::ProposalForm).from_params(params)

          Admin::UpdateProposal.call(@form, @proposal) do
            on(:ok) do |_proposal|
              flash[:notice] = t("proposals.update.success", scope: "decidim")
              redirect_to proposals_path
            end

            on(:invalid) do
              flash.now[:alert] = t("proposals.update.error", scope: "decidim")
              render :edit
            end
          end
        end

        private

        def collection
          @collection ||= Proposal.where(component: current_component).not_hidden.published
        end

        def proposals
          @proposals ||= filtered_collection
        end

        def proposal
          @proposal ||= collection.find(params[:id])
        end

        def proposal_ids
          @proposal_ids ||= params[:proposal_ids]
        end

        def form_presenter
          @form_presenter ||= present(@form, presenter_class: Decidim::Proposals::ProposalPresenter)
        end
      end
    end
  end
end
