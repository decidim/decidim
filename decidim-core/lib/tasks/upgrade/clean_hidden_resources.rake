# frozen_string_literal: true

namespace :decidim do
  namespace :upgrade do
    namespace :clean do
      desc "Removes all related resources from hidden resource"
      task hidden_resources: :environment do
        logger.info("Removing child resources for hidden parents...")
        Decidim::Moderation.hidden.find_each do |moderation_for_hidden_resource|
          reportable = moderation_for_hidden_resource.reportable
          current_user = reportable.organization.users.find_by!(email: Decidim::Ai::SpamDetection.reporting_user_email)
          tool = Decidim::ModerationTools.new(reportable, current_user)
          tool.hide!
        rescue NameError => e
          log_error "Could not hide child resources for reportable id #{moderation_for_hidden_resource.id} because: #{e.message}"
        end
      end

      private

      def log_error(msg)
        puts msg
        Rails.logger.error(msg)
      end
    end
  end
end
