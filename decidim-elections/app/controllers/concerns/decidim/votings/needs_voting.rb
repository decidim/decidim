# frozen_string_literal: true

module Decidim
  module Votings
    # This module, when injected into a controller, ensures there's a
    # voting available and deducts it from the context.
    module NeedsVoting
      def self.enhance_controller(instance_or_module)
        instance_or_module.class_eval do
          helper_method :current_voting
        end
      end

      def self.included(base)
        base.include Decidim::NeedsOrganization, InstanceMethods

        enhance_controller(base)
      end

      module InstanceMethods
        # Public: Finds the current Voting given this controller's
        # context.
        #
        # Returns the current Voting.
        def current_voting
          @current_voting ||= detect_voting
        end

        alias current_participatory_space current_voting

        private

        def detect_voting
          request.env["current_voting"] ||
            organization_votings.find_by(slug: params[:voting_slug] || params[:slug])
        end

        def organization_votings
          @organization_votings ||= OrganizationVotings.new(current_organization).query
        end
      end
    end
  end
end
