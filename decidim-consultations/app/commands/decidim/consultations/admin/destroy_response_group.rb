# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # A command with all the business logic to destroy a response group in the
      # system.
      class DestroyResponseGroup < Decidim::Command
        # Public: Initializes the command.
        #
        # response_group - A ResponseGroup that will be destroyed
        def initialize(response_group)
          @response_group = response_group
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the data wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if response_group.nil? || response_group.responses.any?

          destroy_response_group
          broadcast(:ok)
        end

        private

        attr_reader :response_group

        def destroy_response_group
          response_group.destroy!
        end
      end
    end
  end
end
