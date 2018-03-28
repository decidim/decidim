# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # A command that sets a question as published.
      class PublishQuestion < Rectify::Command
        # Public: Initializes the command.
        #
        # question - A Question that will be published
        def initialize(question)
          @question = question
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the data wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if question.nil? || question.published?

          question.publish!
          broadcast(:ok)
        end

        private

        attr_reader :question
      end
    end
  end
end
