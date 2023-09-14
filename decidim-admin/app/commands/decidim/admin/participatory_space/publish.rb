# frozen_string_literal: true

module Decidim
  module Admin
    module ParticipatorySpace
      # A command that sets a ParticipatorySpace as published.
      class Publish < Decidim::Command
        # Public: Initializes the command.
        #
        # participatory_space - A ParticipatorySpace that will be published
        # user - the user performing the action
        def initialize(participatory_space, user)
          @participatory_space = participatory_space
          @user = user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the data was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if participatory_space.nil? || participatory_space.published?

          Decidim.traceability.perform_action!(:publish, participatory_space, user, **default_options) do
            participatory_space.publish!
          end

          broadcast(:ok, participatory_space)
        end

        private

        attr_reader :participatory_space, :user

        def default_options = { visibility: "all" }
      end
    end
  end
end
