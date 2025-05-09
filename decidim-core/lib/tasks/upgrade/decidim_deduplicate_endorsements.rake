# frozen_string_literal: true

namespace :decidim do
  namespace :upgrade do
    desc "Removes duplicated likes"
    task fix_duplicate_endorsements: :environment do
      logger = Logger.new($stdout)
      logger.info("Removing duplicate likes...")
      has_count = 0

      columns = [:resource_type, :resource_id, :decidim_author_type, :decidim_author_id, :decidim_user_group_id]

      get_duplicates(columns).each do |issue|
        while row_count(issue) > 1
          find_next(issue)&.destroy
          has_count += 1
          logger.info("Removed duplicate like for #{issue.resource_type} #{issue.resource_id}")
        end
      end

      logger.info("Patch remaining likes.")
      Decidim::Like.where(decidim_user_group_id: nil).update(decidim_user_group_id: 0)
      logger.info("Process terminated, #{has_count} likes have been removed.")
      logger.info("Done")
    end

    private

    def get_duplicates(*columns)
      Decidim::Like.select("#{columns.join(",")}, COUNT(*)").group(columns).having("COUNT(*) > 1")
    end

    def row_count(issue)
      Decidim::Like.where(
        resource_type: issue.resource_type,
        resource_id: issue.resource_id,
        decidim_author_type: issue.decidim_author_type,
        decidim_author_id: issue.decidim_author_id,
        decidim_user_group_id: issue.decidim_user_group_id
      ).count
    end

    def find_next(issue)
      Decidim::Like.find_by(
        resource_type: issue.resource_type,
        resource_id: issue.resource_id,
        decidim_author_type: issue.decidim_author_type,
        decidim_author_id: issue.decidim_author_id,
        decidim_user_group_id: issue.decidim_user_group_id
      )
    end
  end
end
