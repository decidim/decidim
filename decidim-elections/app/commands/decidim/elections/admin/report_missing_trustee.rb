# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This command gets called to report a missing trustee during the tally process.
      class ReportMissingTrustee < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A ReportMissingTrusteeForm object with the information needed to report the missing trustee.
        def initialize(form)
          @form = form
        end

        # Public: Reports the missing trustee for the Election tally process.
        #
        # Broadcasts :ok if it worked, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            log_action
            report_missing_trustee
          end

          broadcast(:ok)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_accessor :form

        delegate :election, :bulletin_board, :trustee, to: :form

        def log_action
          Decidim.traceability.perform_action!(
            :report_missing_trustee,
            election,
            form.current_user,
            extra: {
              trustee_id: form.trustee_id,
              name: trustee.name,
              nickname: trustee.user.nickname
            },
            visibility: "all"
          )
        end

        def report_missing_trustee
          bulletin_board.report_missing_trustee(election.id, form.trustee.slug) do |message_id|
            create_election_action(message_id)
          end
        end

        def create_election_action(message_id)
          Decidim::Elections::Action.create!(
            election:,
            action: :report_missing_trustee,
            message_id:,
            status: :pending
          )
        end
      end
    end
  end
end
