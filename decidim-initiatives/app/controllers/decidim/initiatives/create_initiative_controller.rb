# frozen_string_literal: true

module Decidim
  module Initiatives
    # Controller in charge of managing the create initiative wizard.
    class CreateInitiativeController < Decidim::Initiatives::ApplicationController
      layout "layouts/decidim/initiative_creation"

      include Decidim::FormFactory
      include InitiativeHelper
      include TypeSelectorOptions
      include SingleInitiativeType

      helper Decidim::Admin::IconLinkHelper
      helper InitiativeHelper
      helper SignatureTypeOptionsHelper
      helper Decidim::ActionAuthorizationHelper

      helper_method :scopes
      helper_method :areas
      helper_method :current_initiative
      helper_method :initiative_type
      helper_method :promotal_committee_required?
      helper_method :minimum_committee_members
      helper_method :promoters_committee_members

      before_action :authenticate_user!
      before_action :ensure_type_exists,
                    only: [:store_initiative_type, :fill_data, :store_data, :promotal_committee, :finish]
      before_action :ensure_user_can_create_initiative,
                    only: [:fill_data, :store_data, :promotal_committee, :finish]
      before_action :ensure_initiative_exists, only: [:promotal_committee, :finish]

      def load_initiative_draft
        session[:initiative_id] = params[:initiative_id]

        if current_initiative.validating?
          redirect_to finish_create_initiative_index_path
        elsif current_initiative.created?
          redirect_to promotal_committee_create_initiative_index_path
        else
          redirect_to initiatives_path
        end
      end

      def select_initiative_type
        session[:initiative_id] = nil
        @form = form(Decidim::Initiatives::SelectInitiativeTypeForm).from_params(params)

        redirect_to fill_data_create_initiative_index_path if single_initiative_type?
      end

      def store_initiative_type
        @form = form(Decidim::Initiatives::SelectInitiativeTypeForm).from_params(params)

        if @form.valid?
          session[:type_id] = @form.type_id
          redirect_to fill_data_create_initiative_index_path
        else
          render :select_initiative_type
        end
      end

      def fill_data
        @form = if session[:initiative_id].present?
                  form(Decidim::Initiatives::InitiativeForm).from_model(current_initiative, { initiative_type: })
                else
                  extras = { type_id: initiative_type_id, signature_type: initiative_type.signature_type }
                  form(Decidim::Initiatives::InitiativeForm).from_params(params.merge(extras), { initiative_type: })
                end
      end

      def store_data
        if current_initiative
          store_data_update_initiative
        else
          store_data_create_initiative
        end
      end

      def promotal_committee
        redirect_to finish_create_initiative_index_path unless promotal_committee_required?
      end

      def finish
        current_initiative.presence

        if current_initiative.validating?
          session[:type_id] = nil
          session[:initiative_id] = nil
        end
      end

      private

      def store_data_create_initiative
        @form = form(Decidim::Initiatives::InitiativeForm).from_params(params, { initiative_type: })

        CreateInitiative.call(@form) do
          on(:ok) do |initiative|
            session[:initiative_id] = initiative.id

            redirect_to store_data_next_step
          end

          on(:invalid) do
            render :fill_data
          end
        end
      end

      def store_data_update_initiative
        @form = form(Decidim::Initiatives::InitiativeForm).from_params(params, initiative_type: current_initiative.type, initiative: current_initiative)

        UpdateInitiative.call(current_initiative, @form) do
          on(:ok) do
            flash[:notice] = I18n.t("success", scope: "decidim.initiatives.update")
            redirect_to store_data_next_step
          end

          on(:invalid) do
            render :fill_data
          end
        end
      end

      def store_data_next_step
        if promotal_committee_required?
          promotal_committee_create_initiative_index_path
        else
          finish_create_initiative_index_path
        end
      end

      def membership_request
        @membership_request ||= current_initiative.committee_members.find(params[:committee_member_id])
      end

      def ensure_user_can_create_initiative
        enforce_permission_to :create, :initiative, { initiative_type: }
      end

      def initiative_type_id
        @initiative_type_id ||= fetch_initiative_type_id
      end

      def fetch_initiative_type_id
        return current_organization_initiatives_type.first.id if single_initiative_type?
        return params.dig(:initiative, :type_id) if params.dig(:initiative, :type_id).present?
        return current_initiative&.type&.id if session[:initiative_id].present?

        session[:type_id]
      end

      def ensure_initiative_exists
        redirect_to fill_data_create_initiative_index_path if session[:initiative_id].blank?
      end

      def ensure_type_exists
        destination_step = single_initiative_type? ? "fill_data" : "select_initiative_type"

        return if action_name == destination_step
        return if initiative_type_id.present? && initiative_type.present?

        redirect_to send(:"#{destination_step}_create_initiative_index_path")
      end

      def scopes
        @scopes ||= @form.available_scopes
      end

      def current_initiative
        @current_initiative ||= Initiative.where(organization: current_organization, author: current_user).find_by(id: session[:initiative_id] || nil)
      end

      def initiative_types
        @initiative_types ||= InitiativesType.where(organization: current_organization)
      end

      def initiative_type
        @initiative_type ||= initiative_types.find_by(id: initiative_type_id)
      end

      def promotal_committee_required?
        if initiative_type.present?
          initiative_type.promoting_committee_enabled? && minimum_committee_members.positive?
        else
          initiative_types.all?(&:promoting_committee_enabled?)
        end
      end

      def minimum_committee_members
        @minimum_committee_members ||= if initiative_type.blank? || !initiative_type.promoting_committee_enabled?
                                         0
                                       else
                                         initiative_type.minimum_committee_members || Decidim::Initiatives.minimum_committee_members
                                       end
      end

      def promoters_committee_members
        @promoters_committee_members ||= current_initiative.committee_members.approved
      end
    end
  end
end
