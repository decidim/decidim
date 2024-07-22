# frozen_string_literal: true

namespace :decidim do
  namespace :upgrade do
    desc "Removes orphan categorizations"
    task fix_orphan_categorizations: :environment do
      logger = Logger.new($stdout)
      logger.info("Removing orphan categorizations...")

      Decidim::Categorization.find_each do |categorization|
        categorization.destroy if categorization.categorizable.nil?
      end
    end
  end
end
