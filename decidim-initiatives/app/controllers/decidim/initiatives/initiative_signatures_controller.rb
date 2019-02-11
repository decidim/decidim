# frozen_string_literal: true

module Decidim
  module Initiatives
    require "wicked"

    class InitiativeSignaturesController < Decidim::Initiatives::ApplicationController
      layout "layouts/decidim/initiative_signature_creation"

      include Wicked::Wizard
      include Decidim::Initiatives::NeedsInitiative
      include Decidim::FormFactory

      prepend_before_action :set_wizard_steps
      before_action :authenticate_user!

      helper InitiativeHelper

      helper_method :initiative_type, :extra_data_legal_information

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
              error: I18n.t("create.error", scope: "decidim.initiatives.initiative_votes")
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

      def sms_phone_number_step(parameters)
        check_session_personal_data unless parameters.has_key? :initiatives_vote
        clear_session_sms_code
        build_vote_form(parameters)

        @form = Decidim::Verifications::Sms::MobilePhoneForm.new
        render_wizard
      end

      def sms_code_step(parameters)
        check_session_personal_data
        @phone_form = Decidim::Verifications::Sms::MobilePhoneForm.from_params(parameters.merge(user: current_user))
        @form = Decidim::Verifications::Sms::ConfirmationForm.new
        render_wizard && return if session_sms_code.present?

        ValidateMobilePhone.call(@phone_form, current_user) do
          on(:ok) do |metadata|
            store_session_sms_code(metadata)
            render_wizard
          end

          on(:invalid) do
            flash[:alert] = I18n.t("sms_phone.invalid", scope: "decidim.initiatives.initiative_votes")
            redirect_to wizard_path(:sms_phone_number)
          end
        end
      end

      def wicked_finish_step(parameters)
        if parameters.has_key? :initiatives_vote
          build_vote_form(parameters)
        else
          check_session_personal_data
        end

        if sms_step?
          @confirmation_code_form = Decidim::Verifications::Sms::ConfirmationForm.from_params(parameters)

          ValidateSmsCode.call(@confirmation_code_form, session_sms_code) do
            on(:ok) { clear_session_sms_code }

            on(:invalid) do
              flash[:alert] = I18n.t("sms_code.invalid", scope: "decidim.initiatives.initiative_votes")
              jump_to :sms_code
              render_wizard && return
            end
          end
        end

        VoteInitiative.call(@vote_form, current_user) do
          on(:ok) do
            session[:initiative_vote_form] = {}
            flash[:notice] = I18n.t("create.success", scope: "decidim.initiatives.initiative_votes")
            redirect_to initiative_path(current_initiative)
          end

          on(:invalid) do |vote|
            logger.fatal "Failed creating signature: #{vote.errors.full_messages.join(", ")}" if vote
            flash[:alert] = I18n.t("create.invalid", scope: "decidim.initiatives.initiative_votes")
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

      def store_session_sms_code(metadata)
        session[:initiative_sms_code] = metadata
      end

      def session_sms_code
        session[:initiative_sms_code]
      end

      def clear_session_sms_code
        session[:initiative_sms_code] = {}
      end

      def sms_step?
        current_initiative.validate_sms_code_on_votes?
      end

      def set_wizard_steps
        self.steps = sms_step? ? [:fill_personal_data, :sms_phone_number, :sms_code] : [:fill_personal_data]
      end
    end
  end
end
