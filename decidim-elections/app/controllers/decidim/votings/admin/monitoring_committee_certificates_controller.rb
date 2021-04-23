# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # This controller allows to list and validate certificates by the monitoring committee.
      class MonitoringCommitteeCertificatesController < Admin::ApplicationController
        include VotingAdmin

        helper_method :current_voting, :certificates

        def index
          enforce_permission_to :read, :monitoring_committee_certificates, voting: current_voting
        end

        private

        def certificates
          @certificates ||= []
        end
      end
    end
  end
end
