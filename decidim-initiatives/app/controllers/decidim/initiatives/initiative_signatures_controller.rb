# frozen_string_literal: true

module Decidim
  module Initiatives
    require "wicked"

    class InitiativeSignaturesController < Decidim::Initiatives::ApplicationController
      layout "layouts/decidim/initiative_signature_creation"

      include Wicked::Wizard
      include Decidim::Initiatives::NeedsInitiative
      include Decidim::FormFactory

      before_action :authenticate_user!

      helper InitiativeHelper

      helper_method :initiative_type, :extra_data_legal_information

      steps :fill_personal_data

      # GET /initiatives/:initiative_id/initiative_signatures/:step
      def show
        group_id = params[:group_id] || (session[:initiative_vote_form] ||= {})["group_id"]
        enforce_permission_to :sign_initiative, :initiative, initiative: current_initiative, group_id: group_id, signature_has_steps: signature_has_steps?
        send("#{step}_step", initiative_vote_form: session[:initiative_vote_form])
      end

      # PUT /initiatives/:initiative_id/initiative_signatures/:step
      def update
        group_id = params.dig(:initiatives_vote, :group_id) || session[:initiative_vote_form]["group_id"]
        enforce_permission_to :sign_initiative, :initiative, initiative: current_initiative, group_id: group_id, signature_has_steps: signature_has_steps?
        send("#{step}_step", params)
      end

      # POST /initiatives/:initiative_id/initiative_signatures
      def create
        group_id = params[:group_id] || session[:initiative_vote_form]&.dig("group_id")
        enforce_permission_to :vote, :initiative, initiative: current_initiative, group_id: group_id
        @form = form(Decidim::Initiatives::VoteForm)
                .from_params(
                  initiative_id: current_initiative.id,
                  author_id: current_user.id,
                  group_id: group_id
                )

        VoteInitiative.call(@form, current_user) do
          on(:ok) do
            current_initiative.reload
            render :update_buttons_and_counters
          end

          on(:invalid) do
            render json: {
              error: I18n.t("initiative_votes.create.error", scope: "decidim.initiatives")
            }, status: 422
          end
        end
      end

      private

      def fill_personal_data_step(_unused)
        @form = form(Decidim::Initiatives::VoteForm)
                .from_params(
                  initiative_id: current_initiative.id,
                  author_id: current_user.id,
                  group_id: params[:group_id]
                )
        session[:initiative_vote_form] = { group_id: @form.group_id }
        skip_step unless initiative_type.collect_user_extra_fields
        render_wizard
      end

      def wicked_finish_step(parameters)
        if parameters.has_key? :initiatives_vote
          build_vote_form(parameters)
        else
          check_session_personal_data
        end

        VoteInitiative.call(@vote_form, current_user) do
          on(:ok) do
            session[:initiative_vote_form] = {}
            redirect_to initiative_path(current_initiative)
          end

          on(:invalid) do |vote|
            logger.fatal "Failed creating signature: #{vote.errors.full_messages.join(", ")}" if vote
            redirect_to wizard_path(steps.last)
          end
        end
      end

      def build_vote_form(parameters)
        @vote_form = form(Decidim::Initiatives::VoteForm).from_params(parameters).tap do |form|
          form.initiative_id = current_initiative.id
          form.author_id = current_user.id
        end

        session[:initiative_vote_form] = session[:initiative_vote_form].merge(@vote_form.attributes_with_values)
      end

      def session_vote_form
        raw_birth_date = session[:initiative_vote_form]["date_of_birth"]
        return unless raw_birth_date

        @vote_form = form(Decidim::Initiatives::VoteForm).from_params(
          session[:initiative_vote_form].merge("date_of_birth" => Date.parse(raw_birth_date))
        )
      end

      def initiative_type
        @initiative_type ||= current_initiative&.scoped_type&.type
      end

      def extra_data_legal_information
        @extra_data_legal_information ||= initiative_type.extra_fields_legal_information
      end

      def check_session_personal_data
        return if session[:initiative_vote_form].present? && session_vote_form&.valid?

        flash[:alert] = I18n.t("create.error", scope: "decidim.initiatives.initiative_votes")
        jump_to(:fill_personal_data)
      end
    end
  end
end
