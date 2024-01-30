# frozen_string_literal: true

namespace :decidim do
  namespace :upgrade do
    desc "Fix wrongly mapped short links components"
    task fix_short_urls: :environment do
      logger = Logger.new($stdout)
      logger.info("Fixing wrongly mapped short links...")

      Decidim::ShortLink.where(target_type: "Decidim::Component").find_each do |short_url|
        real_component = Decidim::Component.find_by(id: short_url.target_id)

        next if real_component.nil?
        next if short_url.mounted_engine_name == real_component.mounted_engine

        logger.info("Fixing #{short_url.identifier}: #{short_url.mounted_engine_name} to #{real_component.mounted_engine}")
        short_url.update(mounted_engine_name: real_component.mounted_engine)
      end
      logger.info("Done fixing wrongly mapped short links.")
    end
  end
end
