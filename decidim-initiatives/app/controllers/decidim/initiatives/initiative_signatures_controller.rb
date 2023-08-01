# frozen_string_literal: true

# i18n-tasks-use t('layouts.decidim.initiative_signature_creation_header.fill_personal_data')
# i18n-tasks-use t('layouts.decidim.initiative_signature_creation_header.finish')
# i18n-tasks-use t('layouts.decidim.initiative_signature_creation_header.sms_code')
# i18n-tasks-use t('layouts.decidim.initiative_signature_creation_header.sms_phone_number')
# i18n-tasks-use t('layouts.decidim.initiative_signature_creation_header.finish')
module Decidim
  module Initiatives
    class InitiativeSignaturesController < Decidim::Initiatives::ApplicationController
      layout "layouts/decidim/initiative_signature_creation"
      include Decidim::Initiatives::NeedsInitiative
      include Decidim::FormFactory

      prepend_before_action :set_wizard_steps
      before_action :authenticate_user!
      before_action :authorize_wizard_step, only: [
        :fill_personal_data,
        :sms_phone_number,
        :update_sms_phone_number,
        :sms_code,
        :update_sms_code,
        :finish
      ]

      helper InitiativeHelper

      helper_method :initiative_type, :extra_data_legal_information, :sms_step?, :fill_personal_data_step?

      def index
        redirect_to send(fill_personal_data_step? ? :fill_personal_data_path : :sms_phone_number_path)
      end

      # POST /initiatives/:initiative_id/initiative_signatures
      def create
        enforce_permission_to :vote, :initiative, initiative: current_initiative

        @form = form(Decidim::Initiatives::VoteForm)
                .from_params(
                  initiative: current_initiative,
                  signer: current_user
                )

        VoteInitiative.call(@form) do
          on(:ok) do
            current_initiative.reload
            render :update_buttons_and_counters
          end

          on(:invalid) do
            render :error_on_vote, status: :unprocessable_entity
          end
        end
      end

      def fill_personal_data
        redirect_to(sms_phone_number_path) && return unless fill_personal_data_step?

        @form = form(Decidim::Initiatives::VoteForm)
                .from_params(
                  initiative: current_initiative,
                  signer: current_user
                )
      end

      def update_fill_personal_data
        redirect_to(sms_phone_number_path) && return unless fill_personal_data_step?

        build_vote_form(params)

        if @vote_form.invalid?
          flash[:alert] = I18n.t("personal_data.invalid", scope: "decidim.initiatives.initiative_votes")
          @form = @vote_form

          render :fill_personal_data
        else
          redirect_to sms_phone_number_path
        end
      end

      def sms_phone_number
        redirect_to(finish_path) && return unless sms_step?

        @form = Decidim::Verifications::Sms::MobilePhoneForm.new
      end

      def update_sms_phone_number
        redirect_to(finish_path) && return unless sms_step?

        @form = Decidim::Verifications::Sms::MobilePhoneForm.from_params(params.merge(user: current_user))

        ValidateMobilePhone.call(@form, current_user) do
          on(:ok) do |metadata|
            store_session_sms_code(metadata)
            redirect_to sms_code_path
          end

          on(:invalid) do
            flash[:alert] = I18n.t("sms_phone.invalid", scope: "decidim.initiatives.initiative_votes")
            render :sms_phone_number
          end
        end
      end

      def sms_code
        redirect_to(finish_path) && return unless sms_step?

        redirect_to sms_phone_number_path && return if session_sms_code.blank?

        @form = Decidim::Verifications::Sms::ConfirmationForm.new
      end

      def update_sms_code
        redirect_to(finish_path) && return unless sms_step?

        @form = Decidim::Verifications::Sms::ConfirmationForm.from_params(params)
        ValidateSmsCode.call(@form, session_sms_code) do
          on(:ok) do
            clear_session_sms_code
            redirect_to finish_path
          end

          on(:invalid) do
            flash[:alert] = I18n.t("sms_code.invalid", scope: "decidim.initiatives.initiative_votes")
            render :sms_code
          end
        end
      end

      def finish
        if params.has_key?(:initiatives_vote) || !fill_personal_data_step?
          build_vote_form(params)
        else
          check_session_personal_data
        end

        VoteInitiative.call(@vote_form) do
          on(:ok) do
            session[:initiative_vote_form] = {}
          end

          on(:invalid) do |vote|
            logger.fatal "Failed creating signature: #{vote.errors.full_messages.join(", ")}" if vote
            flash[:alert] = I18n.t("create.invalid", scope: "decidim.initiatives.initiative_votes")
            send(sms_step? ? :sms_code_path : :fill_personal_data_path)
          end
        end
      end

      private

      attr_reader :wizard_steps

      def fill_personal_data_path
        fill_personal_data_initiative_initiative_signatures_path(current_initiative)
      end

      def sms_code_path
        sms_code_initiative_initiative_signatures_path(current_initiative)
      end

      def finish_path
        finish_initiative_initiative_signatures_path(current_initiative)
      end

      def sms_phone_number_path
        sms_phone_number_initiative_initiative_signatures_path(current_initiative)
      end

      def build_vote_form(parameters)
        @vote_form = form(Decidim::Initiatives::VoteForm).from_params(parameters).tap do |form|
          form.initiative = current_initiative
          form.signer = current_user
        end

        session[:initiative_vote_form] ||= {}
        session[:initiative_vote_form] = session[:initiative_vote_form].merge(@vote_form.attributes_with_values.except(:initiative, :signer))
      end

      def initiative_type
        @initiative_type ||= current_initiative&.scoped_type&.type
      end

      def sms_step?
        current_initiative.validate_sms_code_on_votes?
      end

      def fill_personal_data_step?
        initiative_type.collect_user_extra_fields?
      end

      def authorize_wizard_step
        enforce_permission_to :sign_initiative, :initiative, initiative: current_initiative, signature_has_steps: signature_has_steps?
      end

      def set_wizard_steps
        @wizard_steps = [:finish]
        @wizard_steps.unshift(:sms_phone_number, :sms_code) if sms_step?
        @wizard_steps.unshift(:fill_personal_data) if fill_personal_data_step?
      end

      def extra_data_legal_information
        @extra_data_legal_information ||= initiative_type.extra_fields_legal_information
      end

      def session_vote_form
        attributes = session[:initiative_vote_form].merge(initiative: current_initiative, signer: current_user)

        @vote_form = form(Decidim::Initiatives::VoteForm).from_params(attributes)
      end

      def check_session_personal_data
        return if session[:initiative_vote_form].present? && session_vote_form&.valid?

        flash[:alert] = I18n.t("create.error", scope: "decidim.initiatives.initiative_votes")
        redirect_to fill_personal_data_path
      end

      def clear_session_sms_code
        session[:initiative_sms_code] = {}
      end

      def store_session_sms_code(metadata)
        session[:initiative_sms_code] = metadata
      end

      def session_sms_code
        session[:initiative_sms_code]
      end
    end
  end
end
