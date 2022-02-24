# frozen_string_literal: true

namespace :decidim do
  namespace :upgrade do
    namespace :moderation do
      desc "Exclude all moderated content from search"
      task remove_from_search: :environment do
        query = Decidim::Moderation.hidden

        log_info "Found #{query.count} hidden resources that needs to be handled"

        query.find_each do |moderation|
          moderation.reportable.remove_from_index(moderation.reportable)
        rescue NameError => e
          log_error "Could not process moderation id #{moderation.id} : #{e.message}"
        end
      end

      private

      def log_info(msg)
        puts msg
        Rails.logger.info(msg)
      end

      def log_error(msg)
        puts msg
        Rails.logger.error(msg)
      end
    end
  end
end
