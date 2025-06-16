# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      class UpdateElectionStatus < Decidim::Command
        def initialize(form, election)
          @form = form
          @election = election
        end

        def call
          return broadcast(:invalid) unless form.valid?

          transaction do
            update_status
            election.save!
          end

          broadcast(:ok, election)
        rescue StandardError => e
          Rails.logger.error "#{e.class.name}: #{e.message}"
          broadcast(:invalid)
        end

        private

        attr_reader :form, :election

        def update_status
          case form.status_action
          when :start
            start_election
          when :end
            end_election
          end
        end

        def start_election
          election.start_at = Time.current
        end

        def end_election
          election.end_at = Time.current
        end
      end
    end
  end
end
