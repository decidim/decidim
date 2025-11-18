# frozen_string_literal: true

namespace :decidim do
  namespace :upgrade do
    desc "Fixes the visibility of menu_hidden action logs"
    task :fix_action_log => :environment do
      logger.info("Fixing action log menu_hidden actions...")

      count = Decidim::ActionLog.where(action: "menu_hidden").where.not(visibility: "admin-only").count
      logger.info "Found #{count} action logs to update."
      if count.positive?
        # ActionLog is a read-only model, so we need to use raw SQL to update the records
        ActiveRecord::Base.connection.execute("UPDATE decidim_action_logs SET visibility = 'admin-only' WHERE action = 'menu_hidden'")
        if Decidim::ActionLog.where(action: "menu_hidden").where.not(visibility: "admin-only").count.zero?
          logger.info("Successfully updated #{count} action logs.")
        else
          logger.error("Failed to update all action logs. Please check the database.")
        end
      end
    end

    private

    def logger
      @logger ||= Logger.new($stdout)
    end
  end
end
