# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # A command with all the business logic for a monitornig committee member to validate a polling station closure
      class MonitoringCommitteeValidatePollingStationClosure < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # closure - A closure object.
        def initialize(form, closure)
          @form = form
          @closure = closure
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          closure.update!(validated_at: Time.current, monitoring_committee_notes: form.monitoring_committee_notes)

          broadcast(:ok)
        rescue ActiveRecord::RecordInvalid
          broadcast(:invalid)
        end

        attr_reader :form, :closure
      end
    end
  end
end
