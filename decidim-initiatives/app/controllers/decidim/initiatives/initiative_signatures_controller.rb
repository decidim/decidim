# frozen_string_literal: true

module Decidim
  module Initiatives
    class InitiativeSignaturesController < Decidim::Initiatives::ApplicationController
      layout "layouts/decidim/initiative_signature_creation"
      include Decidim::Initiatives::NeedsInitiative
      include Decidim::FormFactory
      include Decidim::Initiatives::HasSignatureWorkflow

      prepend_before_action :set_wizard_steps
      before_action :authenticate_user!, unless: :ephemeral_signature_workflow?
      skip_before_action :check_ephemeral_user_session

      before_action :authorize_wizard_step, only: [
        :fill_personal_data,
        :store_personal_data,
        :sms_phone_number,
        :store_sms_phone_number,
        :sms_code,
        :store_sms_code,
        :finish
      ]

      before_action :set_ephemeral_user, if: :ephemeral_signature_workflow?, only: :index

      helper InitiativeHelper

      helper_method :initiative_type, :extra_data_legal_information, :sms_step?, :fill_personal_data_step?

      def index
        redirect_to send(fill_personal_data_step? ? :fill_personal_data_path : :sms_phone_number_path)
      end

      # POST /initiatives/:initiative_id/initiative_signatures
      def create
        enforce_permission_to :vote, :initiative, initiative: current_initiative

        @form = form(signature_form_class).from_params(
          initiative: current_initiative,
          user: current_user
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

        @form = form(signature_form_class).from_params(
          initiative: current_initiative,
          user: current_user
        )
      end

      def store_personal_data
        redirect_to(sms_phone_number_path) && return unless fill_personal_data_step?

        build_vote_form(params)

        if @vote_form.already_voted?
          flash[:alert] = I18n.t("create.already_voted", scope: "decidim.initiatives.initiative_votes")
          clear_authorization_path
          redirect_to initiative_path(current_initiative)
        elsif @vote_form.invalid?
          @form = @vote_form

          render :fill_personal_data
        else
          redirect_to sms_phone_number_path
        end
      end

      def sms_phone_number
        return redirect_to fill_personal_data_path if fill_personal_data_step? && session[:initiative_vote_form].blank?
        return redirect_to(finish_path) unless sms_step?

        @form = sms_mobile_phone_form_class.new
      end

      def store_sms_phone_number
        redirect_to(finish_path) && return unless sms_step?

        @form = sms_mobile_phone_form_class.from_params(params.merge(user: current_user))

        sms_mobile_phone_validator_class.call(@form, current_user) do
          on(:ok) do |metadata|
            store_session_sms_code(metadata, @form.mobile_phone_number)
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

        return redirect_to sms_phone_number_path if session_sms_code.blank?

        @sms_code_form = Decidim::Verifications::Sms::ConfirmationForm.new
        @phone_number_form = sms_mobile_phone_form_class.from_params(mobile_phone_number: session_sms_code[:phone_number], user: current_user)
      end

      def store_sms_code
        redirect_to(finish_path) && return unless sms_step?

        @sms_code_form = Decidim::Verifications::Sms::ConfirmationForm.from_params(params)
        sms_code_validator_class.call(@sms_code_form, session_sms_code) do
          on(:ok) do
            respond_to do |format|
              format.js do
                render json: { sms_code: "OK" }
              end

              format.html do
                clear_session_sms_code
                redirect_to finish_path
              end
            end
          end

          on(:invalid) do
            respond_to do |format|
              format.js do
                render json: { sms_code: "KO" }
              end

              format.html do
                flash[:alert] = I18n.t("sms_code.invalid", scope: "decidim.initiatives.initiative_votes")
                render :sms_code
              end
            end
          end
        end
      end

      def finish
        if params.has_key?(:initiatives_vote) || !fill_personal_data_step?
          build_vote_form(params)
        else
          check_session_personal_data
        end

        return if @vote_form.blank?

        VoteInitiative.call(@vote_form) do
          on(:ok) do
            session[:initiative_vote_form] = {}
            clear_authorization_path
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
        fill_personal_data_initiative_signatures_path(current_initiative)
      end

      def sms_code_path
        sms_code_initiative_signatures_path(current_initiative)
      end

      def finish_path
        finish_initiative_signatures_path(current_initiative)
      end

      def sms_phone_number_path
        sms_phone_number_initiative_signatures_path(current_initiative)
      end

      def build_vote_form(parameters)
        @vote_form = form(signature_form_class).from_params(parameters).tap do |form|
          form.initiative = current_initiative
          form.user = current_user
        end

        @vote_form.validate

        if @vote_form.transfer_status == :transfer_user && @vote_form.user != current_user
          new_user = @vote_form.user
          new_user.update(last_sign_in_at: Time.current, deleted_at: nil)
          sign_out(current_user)
          sign_in(new_user)
        elsif @vote_form.transfer_status.is_a?(Decidim::AuthorizationTransfer)
          transfer = @vote_form.transfer_status

          message = t("authorizations.create.success", scope: "decidim.verifications")
          if transfer.records.any?
            message = <<~HTML
              <p>#{CGI.escapeHTML(message)}</p>
              <p>#{CGI.escapeHTML(t("authorizations.create.transferred", scope: "decidim.verifications"))}</p>
              #{transfer.presenter.records_list_html}
            HTML
          end

          flash[:notice] = message
        end

        session[:initiative_vote_form] ||= {}
        session[:initiative_vote_form] = session[:initiative_vote_form].merge(@vote_form.attributes_with_values.except(:initiative, :user, :transfer_status))
      end

      def initiative_type
        @initiative_type ||= current_initiative&.scoped_type&.type
      end

      def sms_step?
        current_initiative.organization.available_authorizations.include?("sms") && signature_workflow_manifest.sms_verification
      end

      def fill_personal_data_step?
        signature_form_class.requires_extra_attributes?
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
        attributes = session[:initiative_vote_form].merge(initiative: current_initiative, user: current_user)

        @vote_form = form(signature_form_class).from_params(attributes)
      end

      def check_session_personal_data
        return if session[:initiative_vote_form].present? && session_vote_form&.valid?

        flash[:alert] = I18n.t("create.error", scope: "decidim.initiatives.initiative_votes")
        redirect_to fill_personal_data_path
      end

      def clear_session_sms_code
        session[:initiative_sms_code] = {}
      end

      def store_session_sms_code(metadata, phone_number)
        session[:initiative_sms_code] = metadata.merge(phone_number:)
      end

      def session_sms_code
        (session[:initiative_sms_code] || {}).symbolize_keys
      end

      def clear_authorization_path
        return unless current_user.ephemeral? && onboarding_manager.authorization_path.present?

        base_path = initiatives_path
        return if onboarding_manager.authorization_path == base_path

        current_user.update(extended_data: current_user.extended_data.deep_merge("onboarding" => { "authorization_path" => base_path }))
      end

      def set_ephemeral_user
        if user_signed_in?
          update_onboarding_data
        else
          create_ephemeral_user
        end
      end

      def update_onboarding_data
        return unless current_user.ephemeral?
        return if onboarding_manager.model == current_initiative

        current_user.update(extended_data: current_user.extended_data.deep_merge("onboarding" => current_initiative_onboarding_data))
      end

      def create_ephemeral_user
        form = Decidim::EphemeralUserForm.new(
          organization: current_organization,
          locale: current_locale,
          onboarding_data: current_initiative_onboarding_data
        )
        CreateEphemeralUser.call(form) do
          on(:ok) do |ephemeral_user|
            sign_in(ephemeral_user)
          end
        end
      end

      def current_initiative_onboarding_data
        {
          "model" => current_initiative.to_gid,
          "permissions_holder" => initiative_type.to_gid,
          "action" => "vote",
          "redirect_path" => initiative_path(current_initiative),
          "authorization_path" => initiative_signatures_path(current_initiative)
        }
      end
    end
  end
end
