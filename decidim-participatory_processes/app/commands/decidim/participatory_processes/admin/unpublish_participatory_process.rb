# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command that sets a participatory process as unpublished.
      class UnpublishParticipatoryProcess < Decidim::Command
        # Public: Initializes the command.
        #
        # process - A ParticipatoryProcess that will be unpublished
        # current_user - the user performing this action
        def initialize(process, current_user)
          @process = process
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the data wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if process.nil? || !process.published?

          transaction do
            Decidim.traceability.perform_action!("unpublish", process, current_user) do
              process.unpublish!
            end
          end
          broadcast(:ok)
        end

        private

        attr_reader :process, :current_user
      end
    end
  end
end
