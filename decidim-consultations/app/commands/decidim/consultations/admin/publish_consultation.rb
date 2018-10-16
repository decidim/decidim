# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # A command that sets a consultation as published.
      class PublishConsultation < Rectify::Command
        # Public: Initializes the command.
        #
        # consultation - A Consultation that will be published
        # current_user - the user performing the action
        def initialize(consultation, current_user)
          @consultation = consultation
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the data wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if consultation.nil? || consultation.published?

          Decidim.traceability.perform_action!("publish", consultation, current_user, visibility: "all") do
            consultation.publish!
          end

          broadcast(:ok)
        end

        private

        attr_reader :consultation, :current_user
      end
    end
  end
end
