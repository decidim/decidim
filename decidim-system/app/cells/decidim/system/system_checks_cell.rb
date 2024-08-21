# frozen_string_literal: true

module Decidim
  module System
    class SystemChecksCell < Decidim::ViewModel
      def show
        render
      end

      private

      def checks
        {
          secret_key: {
            check_method: correct_secret_key_base?,
            error_extra: generated_secret_key
          },
          active_job_queue: {
            check_method: correct_active_job_queue?,
            error_extra: active_job_queue_link
          }
        }
      end

      def correct_secret_key_base?
        Rails.application.secret_key_base&.length == 128
      end

      def generated_secret_key
        SecureRandom.hex(64)
      end

      def correct_active_job_queue?
        # The default ActiveJob queue is not recommended for production environments,
        # as it can lose jobs when restarting
        Rails.application.config.active_job.queue_adapter != :async
      end

      def active_job_queue_link
        link_to(t("active_job_queue.decidim_documentation", scope: "decidim.system.system_checks"),
                "https://docs.decidim.org/en/develop/services/activejob",
                class: "underline text-primary",
                target: "_blank",
                rel: "nofollow noopener noreferrer")
      end
    end
  end
end
