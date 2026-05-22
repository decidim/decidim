# frozen_string_literal: true

module Decidim
  module Elections
    module UsesCensusAccess
      extend ActiveSupport::Concern

      included do
        helper_method :exit_path, :election, :session_authenticated?, :session_attributes, :voter_uid
      end

      private

      def election
        @election ||= Election.where(component: current_component).published.find(params.expect(:election_id))
      end

      def session_authenticated?
        @session_authenticated ||= election.census.valid_user?(election, session_attributes, current_user:)
      end

      def voter_uid
        @voter_uid ||= election.census.voter_uid(election, session_attributes, current_user:)
      end

      def session_attributes
        session[:session_attributes] ||= {}
      end

      def exit_path
        @exit_path ||= if allowed_to?(:read, :election, election:)
                         election_path(election)
                       else
                         elections_path
                       end
      end
    end
  end
end
