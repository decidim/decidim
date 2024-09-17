# frozen_string_literal: true

namespace :decidim do
  namespace :upgrade do
    namespace :clean do
      desc "Removes all the invalid records from search, notifications, follows and action_logs"
      task invalid_records: [
        :"decidim:upgrade:clean:searchable_resources",
        :"decidim:upgrade:clean:notifications",
        :"decidim:upgrade:clean:follows",
        :"decidim:upgrade:clean:categories",
        :"decidim:upgrade:clean:action_logs"
      ]

      desc "Removes any action logs belonging to invalid resources"
      task :action_logs, [] => :environment do
        logger.info("=== Deleting Action logs")
        invalid = 0
        Decidim::ActionLog.find_each do |log|
          log.participatory_space if log.participatory_space_type.present?
          log.resource if log.resource_type.present?

          if log.resource_type == "Decidim::Component" && log.resource.blank?
            log.delete
            invalid += 1
          end

          next if log.decidim_component_id.blank?
          next if log.component.present?

          log.delete
          invalid += 1
        rescue NameError
          log.delete
          invalid += 1
        end
        logger.info("===== Deleted #{invalid} invalid action logs")
      end

      desc "Removes any follows belonging to invalid resources"
      task :follows, [] => :environment do
        logger.info("=== Deleting Follows")
        invalid = 0
        Decidim::Follow.find_each do |follow|
          follow.followable

          next unless follow.followable.respond_to?(:component)
          next if follow.followable.component.present?

          # We attempt to remove any of the follows that refer to spaces or components that disappeared
          follow.destroy
          invalid += 1
        rescue NameError
          # We use delete as we do not want to call the hooks
          follow.delete
          invalid += 1
        end
        logger.info("===== Deleted #{invalid} invalid follows")
      end

      desc "Removes any notifications belonging to invalid resources"
      task :notifications, [] => :environment do
        logger.info("=== Deleting Notification")
        invalid = 0
        Decidim::Notification.find_each do |notification|
          # Check if the resource class still exists
          notification.resource
          # Check if the event class still exists
          notification.event_class_instance
        rescue NameError
          notification.destroy
          invalid += 1
        end
        logger.info("===== Deleted #{invalid} invalid notifications")
      end

      desc "Removes any resources from search index that do not exist"
      task :searchable_resources, [] => :environment do
        logger.info("=== Deleting Searchable results")
        logger.info("==== Deleting invalid spaces ")
        invalid = 0
        Decidim::SearchableResource.where.not(decidim_participatory_space_type: nil).find_each do |search|
          search.decidim_participatory_space
        rescue NameError
          search.destroy!
          invalid += 1
        end
        logger.info("===== Deleted #{invalid} invalid spaces")

        logger.info("==== Deleting invalid resources from search index ")
        invalid = 0
        Decidim::SearchableResource.find_each do |search|
          next unless search.resource.respond_to?(:component)
          next if search.resource.component.present?

          search.destroy
          invalid += 1
        rescue NameError
          search.destroy!
          invalid += 1
        end
        logger.info("===== Deleted #{invalid} invalid resources")
      end

      desc "Removes any categorizations belonging to invalid resources"
      task categories: :environment do
        logger.info("=== Removing orphan categorizations...")
        invalid = 0

        Decidim::Categorization.find_each do |categorization|
          next unless categorization.categorizable.nil?

          invalid += 1
          categorization.destroy
        rescue NameError
          categorization.destroy!
          invalid += 1
        end
        logger.info("===== Deleted #{invalid} invalid resources")
      end

      def logger
        @logger ||= Logger.new($stdout)
      end
    end
  end
end
