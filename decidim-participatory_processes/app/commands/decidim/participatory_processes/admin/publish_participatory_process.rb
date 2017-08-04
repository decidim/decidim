# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command that sets a participatory process as published.
      class PublishParticipatoryProcess < Rectify::Command
        # Public: Initializes the command.
        #
        # process - A ParticipatoryProcess that will be published
        def initialize(process)
          @process = process
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the data wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if process.nil? || process.published?

          process.publish!
          broadcast(:ok)
        end

        private

        attr_reader :process
      end
    end
  end
end
