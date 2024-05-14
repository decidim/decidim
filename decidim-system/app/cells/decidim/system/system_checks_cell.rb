# frozen_string_literal: true

module Decidim
  module System
    class SystemChecksCell < Decidim::ViewModel
      def show
        render
      end

      private

      def correct_secret_key_base?
        Rails.application.secrets.secret_key_base.length == 128
      end

      def generated_secret_key
        SecureRandom.hex(64)
      end

      def correct_active_job_queue?
        # The default ActiveJob queue is not recommended for production environments,
        # as it can lose jobs when restarting
        Rails.application.config.active_job.queue_adapter != :async
      end
    end
  end
end
