# frozen_string_literal: true

module Decidim
  module Elections
    # Allows participants to verify they belong to an election census before voting starts.
    class CensusChecksController < Decidim::Elections::ApplicationController
      include UsesCensusAccess

      layout "decidim/election_booth"

      before_action :ensure_census_available!
      before_action :redirect_if_authenticated, only: :new
      before_action :ensure_session_authenticated!, only: :show

      def new
        enforce_permission_to(:create, :census_check, election:)

        @form = build_form
        render "decidim/elections/votes/new"
      end

      def create
        enforce_permission_to(:create, :census_check, election:)

        @form = election.census.form_instance(params, election:, current_user:)
        if @form&.valid?
          session[:session_attributes] = @form.attributes
          redirect_to election_census_check_path(election)
        else
          error_messages = @form&.errors&.full_messages
          flash[:alert] = if error_messages.present?
                            error_messages.join("<br>")
                          else
                            t("decidim.elections.votes.check_census.failed")
                          end
          redirect_to new_election_census_check_path(election)
        end
      end

      def show
        enforce_permission_to(:read, :census_check, election:)
      end

      private

      def build_form
        election.census.form_instance({}, election:, current_user:)
      end

      def ensure_census_available!
        return if election.census&.auth_form? && election.census_ready?

        redirect_to exit_path, alert: t("decidim.elections.census_checks.not_ready")
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
