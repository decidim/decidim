# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # A command that sets a consultation results as unpublished.
      class UnpublishConsultationResults < Decidim::Command
        # Public: Initializes the command.
        #
        # consultation - A Consultation that will get its results unpublished
        def initialize(consultation)
          @consultation = consultation
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the data wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if consultation.nil? || !consultation.results_published?

          consultation.unpublish_results!
          broadcast(:ok)
        end

        private

        attr_reader :consultation
      end
    end
  end
end
