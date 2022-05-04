# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # A command that sets a question as published.
      class PublishQuestion < Decidim::Command
        # Public: Initializes the command.
        #
        # question - A Question that will be published
        # current_user - the user performing the action
        def initialize(question, current_user)
          @question = question
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the data wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if question.nil? || question.published?

          Decidim.traceability.perform_action!("publish", question, @current_user, visibility: "all") do
            question.publish!
          end

          broadcast(:ok)
        end

        private

        attr_reader :question
      end
    end
  end
end
