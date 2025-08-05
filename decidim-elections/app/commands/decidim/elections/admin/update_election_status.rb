# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      class UpdateElectionStatus < Decidim::Command
        def initialize(action, election)
          @action = action.to_sym
          @election = election
        end

        def call
          return broadcast(:invalid) unless action.in?([:start, :end, :publish_results])

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

        attr_reader :action, :election

        def update_status
          case action
          when :start
            election.start_at = Time.current
          when :end
            election.end_at = Time.current
          when :publish_results
            election.published_results_at = Time.current
          end
        end
      end
    end
  end
end
