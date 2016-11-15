# frozen_string_literal: true
module Decidim
  module Admin
    # A command that sets a participatory process as unpublished.
    class UnpublishParticipatoryProcess < Rectify::Command
      # Public: Initializes the command.
      #
      # process - A ParticipatoryProcess that will be unpublished
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
        return broadcast(:invalid) if process.nil? || !process.published?

        unpublish_process
        broadcast(:ok)
      end

      private

      attr_reader :process

      def unpublish_process
        process.update_attribute(:published_at, nil)
      end
    end
  end
end
