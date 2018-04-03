# frozen_string_literal: true

module Decidim
  module Initiatives
    # A command with all the business logic that creates a new membership
    # request for the committee of an initiative.
    class SpawnCommitteeRequest < Rectify::Command
      # Public: Initializes the command.
      #
      # initiative - Decidim::Initiative
      # current_user - Decidim::User
      def initialize(initiative, current_user)
        @initiative = initiative
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        request = create_request

        if request.persisted?
          broadcast(:ok, request)
        else
          broadcast(:invalid, request)
        end
      end

      private

      attr_reader :initiative, :current_user

      def create_request
        request = InitiativesCommitteeMember.new(
          decidim_initiatives_id: initiative&.id,
          decidim_users_id: current_user&.id,
          state: "requested"
        )
        return request unless request.valid?

        request.save
        request
      end
    end
  end
end
