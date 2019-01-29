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
        group_id = params[:group_id] || (session[:initiatives_vote] ||= {})["group_id"]
        enforce_permission_to :sign_initiative, :initiative, initiative: current_initiative, group_id: group_id, signature_has_steps: signature_has_steps?
        send("#{step}_step", initiatives_vote: session[:initiatives_vote])
      end

      # PUT /initiatives/:initiative_id/initiative_signatures/:step
      def update
        group_id = params[:initiatives_vote][:group_id] || session[:initiatives_vote]["group_id"]
        enforce_permission_to :sign_initiative, :initiative, initiative: current_initiative, group_id: group_id, signature_has_steps: signature_has_steps?
        send("#{step}_step", params)
      end

      # POST /initiatives/:initiative_id/initiative_signatures
      def create
        group_id = params[:group_id] || session[:initiatives_vote] && session[:initiatives_vote]["group_id"]
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
        session[:initiatives_vote] = { group_id: @form.group_id }
        skip_step unless initiative_type.collect_user_extra_fields
        render_wizard
      end

      def wicked_finish_step(parameters)
        @form = build_form(Decidim::Initiatives::VoteForm, parameters)

        VoteInitiative.call(@form, current_user) do
          on(:ok) do
            session[:initiatives_vote] = {}
            redirect_to initiative_path(@form.initiative)
          end

          on(:invalid) do |vote|
            logger.fatal "Failed creating signature: #{vote.errors.full_messages.join(", ")}" if vote
            redirect_to previous_wizard_path(validate_form: true)
          end
        end
      end

      def build_form(klass, parameters)
        @form = form(klass).from_params(parameters).tap do |form|
          form.initiative_id = current_initiative.id
          form.author_id = current_user.id
        end

        attributes = @form.attributes_with_values
        session[:initiatives_vote] = session[:initiatives_vote].merge(attributes)

        @form
      end

      def initiative_type
        @initiative_type ||= current_initiative&.scoped_type&.type
      end

      def extra_data_legal_information
        @extra_data_legal_information ||= initiative_type.extra_fields_legal_information
      end
    end
  end
end
