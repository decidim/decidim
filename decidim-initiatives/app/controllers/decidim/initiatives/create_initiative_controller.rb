# frozen_string_literal: true

module Decidim
  module Initiatives
    require "wicked"

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

      helper_method :similar_initiatives
      helper_method :scopes
      helper_method :areas
      helper_method :current_initiative
      helper_method :initiative_type
      helper_method :promotal_committee_required?

      before_action :authenticate_user!
      before_action :ensure_type_exists, only: [:previous_form, :fill_data, :show_similar_initiatives, :promotal_committee, :finish]
      before_action :ensure_initiative_exists, only: [:fill_data, :show_similar_initiatives, :promotal_committee, :finish]

      def select_initiative_type
        redirect_to previous_form_create_initiative_index_path if single_initiative_type?
        @form = form(Decidim::Initiatives::SelectInitiativeTypeForm).from_params(params)

        render :select_initiative_type && return unless request.put?

        if @form.valid?
          session[:type_id] = @form.type_id
          redirect_to previous_form_create_initiative_index_path
        end
      end

      def previous_form
        @form = form(Decidim::Initiatives::PreviousForm).from_params({ type_id: initiative_type_id })

        enforce_permission_to :create, :initiative, { initiative_type: }

        render :previous_form && return unless request.put?

        @form = form(Decidim::Initiatives::PreviousForm).from_params(params, { initiative_type: })
        CreateInitiative.call(@form, current_user) do
          on(:ok) do |initiative|
            session[:initiative_id] = initiative.id
            redirect_to show_similar_initiatives_create_initiative_index_path
          end
        end
      end

      def show_similar_initiatives
        @form = form(Decidim::Initiatives::PreviousForm).from_model(current_initiative)

        redirect_to fill_data_create_initiative_index_path if similar_initiatives.empty?
      end

      def fill_data
        @form = form(Decidim::Initiatives::InitiativeForm).from_model(current_initiative, { initiative_type: })

        render :fill_data && return unless request.put?

        enforce_permission_to :create, :initiative, { initiative_type: }

        @form = form(Decidim::Initiatives::InitiativeForm).from_params(params, { initiative_type: })
        UpdateInitiative.call(current_initiative, @form, current_user) do
          on(:ok) do
            path = promotal_committee_required? ? "promotal_committee" : "finish"

            redirect_to send("#{path}_create_initiative_index_path".to_sym)
          end
        end
      end

      def promotal_committee
        redirect_to finish_create_initiative_index_path unless promotal_committee_required?
      end

      def finish; end

      private

      def initiative_type_id
        @initiative_type_id ||= get_initiative_type_id
      end

      def get_initiative_type_id
        return current_organization_initiatives_type.first.id if single_initiative_type?
        return current_initiative&.type&.id if session[:initiative_id].present?
        
        session[:type_id]
      end
      def ensure_initiative_exists
        redirect_to previous_form_create_initiative_index_path if session[:initiative_id].blank?
      end

      def ensure_type_exists
        destination_step = single_initiative_type? ? "previous_form" : "select_initiative_type"

        return if action_name == destination_step
        return if initiative_type_id.present? && initiative_type.present?

        redirect_to send("#{destination_step}_create_initiative_index_path".to_sym)
      end

      def similar_initiatives
        @similar_initiatives ||= Decidim::Initiatives::SimilarInitiatives
                                 .for(current_organization, @form)
                                 .all
      end

      def scopes
        @scopes ||= @form.available_scopes
      end

      def current_initiative
        Initiative.find(session[:initiative_id] || nil)
      end

      def initiative_type
        @initiative_type ||= InitiativesType.find(initiative_type_id)
      end

      def promotal_committee_required?
        return false unless initiative_type.promoting_committee_enabled?

        minimum_committee_members = initiative_type.minimum_committee_members ||
                                    Decidim::Initiatives.minimum_committee_members
        minimum_committee_members.present? && minimum_committee_members.positive?
      end
    end
  end
end
