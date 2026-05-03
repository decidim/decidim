# frozen_string_literal: true

module Decidim
  module Elections
    # Allows participants to verify they belong to an election census before voting starts.
    class CensusChecksController < Decidim::Elections::ApplicationController
      include UsesCensusAccess

      layout "decidim/election_booth"

      before_action :redirect_if_authenticated, only: :new
      before_action :ensure_session_authenticated!, only: :show

      def new
        enforce_permission_to(:create, :census_check, election:)

        @form = election.census.form_instance({}, election:, current_user:)
        render "decidim/elections/votes/new"
      end

      def create
        enforce_permission_to(:create, :census_check, election:)

        @form = election.census.form_instance(params, election:, current_user:)
        if @form.valid?
          session[:session_attributes] = @form.attributes
          redirect_to election_census_check_path(election)
        else
          flash[:alert] = @form.errors.full_messages.join("<br>").presence || t("failed", scope: "decidim.elections.votes.check_census")
          redirect_to new_election_census_check_path(election)
        end
      end

      def show
        enforce_permission_to(:read, :census_check, election:)
      end

      private

      # Allows admins to access unpublished elections for preview.
      def election
        @election ||= Election.where(component: current_component)
                              .then { |scope| current_user&.admin? ? scope : scope.published }
                              .find(params[:election_id])
      end

      def redirect_if_authenticated
        redirect_to election_census_check_path(election) if session_authenticated?
      end

      def ensure_session_authenticated!
        return if session_authenticated?

        redirect_to new_election_census_check_path(election), alert: t("decidim.elections.votes.check_census.failed")
      end
    end
  end
end
