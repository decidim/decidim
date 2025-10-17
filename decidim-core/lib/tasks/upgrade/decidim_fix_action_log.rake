# frozen_string_literal: true

namespace :decidim do
  namespace :upgrade do
    desc "Fixes the visibility of menu_hidden action logs"
    task :fix_action_log => :environment do
      logger.info("Fixing action log menu_hidden actions...")

      updated_count = 0
      Decidim::ActionLog.where(action: "menu_hidden").find_each do |action_log|
        action_log.update_column(:visibility, "admin-only") # rubocop:disable Rails/SkipsModelValidations
        updated_count += 1
      end

      logger.info("Process terminated, #{updated_count} action logs have been updated.")
    end

    private

    def logger
      @logger ||= Logger.new($stdout)
    end
  end
end
