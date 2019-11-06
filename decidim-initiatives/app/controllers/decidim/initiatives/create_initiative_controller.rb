# frozen_string_literal: true

module Decidim
  module Initiatives
    require "wicked"

    # Controller in charge of managing the create initiative wizard.
    class CreateInitiativeController < Decidim::Initiatives::ApplicationController
      layout "layouts/decidim/initiative_creation"

      include Wicked::Wizard
      include Decidim::FormFactory
      include InitiativeHelper
      include TypeSelectorOptions

      helper Decidim::Admin::IconLinkHelper
      helper InitiativeHelper
      helper_method :similar_initiatives
      helper_method :scopes
      helper_method :current_initiative
      helper_method :initiative_type
      helper_method :promotal_committee_required?

      steps :select_initiative_type,
            :previous_form,
            :show_similar_initiatives,
            :fill_data,
            :promotal_committee,
            :finish

      def show
        enforce_permission_to :create, :initiative
        send("#{step}_step", initiative: session_initiative)
      end

      def update
        enforce_permission_to :create, :initiative
        send("#{step}_step", params)
      end

      private

      def select_initiative_type_step(_parameters)
        @form = form(Decidim::Initiatives::SelectInitiativeTypeForm).instance
        session[:initiative] = {}
        render_wizard
      end

      def previous_form_step(parameters)
        @form = build_form(Decidim::Initiatives::PreviousForm, parameters)
        render_wizard
      end

      def show_similar_initiatives_step(parameters)
        @form = build_form(Decidim::Initiatives::PreviousForm, parameters)
        unless @form.valid?
          redirect_to previous_wizard_path(validate_form: true)
          return
        end

        if similar_initiatives.empty?
          @form = build_form(Decidim::Initiatives::InitiativeForm, parameters)
          redirect_to wizard_path(:fill_data)
        end

        render_wizard unless performed?
      end

      def fill_data_step(parameters)
        @form = build_form(Decidim::Initiatives::InitiativeForm, parameters)
        render_wizard
      end

      def promotal_committee_step(parameters)
        skip_step unless promotal_committee_required?

        if session_initiative.has_key?(:id)
          render_wizard
          return
        end

        @form = build_form(Decidim::Initiatives::InitiativeForm, parameters)

        CreateInitiative.call(@form, current_user) do
          on(:ok) do |initiative|
            session[:initiative][:id] = initiative.id
            if current_initiative.created_by_individual?
              render_wizard
            else
              redirect_to wizard_path(:finish)
            end
          end

          on(:invalid) do |initiative|
            logger.fatal "Failed creating initiative: #{initiative.errors.full_messages.join(", ")}" if initiative
            redirect_to previous_wizard_path(validate_form: true)
          end
        end
      end

      def finish_step(_parameters)
        render_wizard
      end

      def similar_initiatives
        @similar_initiatives ||= Decidim::Initiatives::SimilarInitiatives
                                 .for(current_organization, @form)
                                 .all
      end

      def build_form(klass, parameters)
        @form = form(klass).from_params(parameters)
        attributes = @form.attributes_with_values
        session[:initiative] = session_initiative.merge(attributes)
        @form.valid? if params[:validate_form]

        @form
      end

      def scopes
        @scopes ||= @form.available_scopes
      end

      def current_initiative
        Initiative.find(session_initiative[:id]) if session_initiative.has_key?(:id)
      end

      def initiative_type
        @initiative_type ||= InitiativesType.find(session_initiative[:type_id] || @form&.type_id)
      end

      def session_initiative
        session[:initiative] ||= {}
        session[:initiative].with_indifferent_access
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
