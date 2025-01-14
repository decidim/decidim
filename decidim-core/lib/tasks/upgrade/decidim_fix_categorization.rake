# frozen_string_literal: true

namespace :decidim do
  namespace :upgrade do
    namespace :clean do
      desc "Removes all the invalid records from search, notifications, follows and action_logs"
      task invalid_records: [
        :"decidim:upgrade:clean:searchable_resources",
        :"decidim:upgrade:clean:notifications",
        :"decidim:upgrade:clean:follows",
        :"decidim:upgrade:clean:action_logs",
        :"decidim:upgrade:clean:clean_deleted_users",
        :"decidim:upgrade:clean:fix_blocked_user_notification"
      ]

      desc "Remove data from deleted users"
      task clean_deleted_users: :environment do
        logger = Logger.new($stdout)
        logger.info("=== Removing extra data from deleted users")
        Decidim::User.where.not(deleted_at: nil).update_all(personal_url: "", about: "", notifications_sending_frequency: "none") # rubocop:disable Rails/SkipsModelValidations
      end

      desc "Removes any action logs belonging to invalid resources"
      task :action_logs, [] => :environment do
        puts "=== Deleting Action logs\n"
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
        puts "===== Deleted #{invalid} invalid action logs\n"
      end

      desc "Removes any follows belonging to invalid resources"
      task :follows, [] => :environment do
        puts "=== Deleting Follows\n"
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
        puts "===== Deleted #{invalid} invalid follows\n"
      end

      desc "Removes any notifications belonging to invalid resources"
      task :notifications, [] => :environment do
        puts "=== Deleting Notification\n"
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
        puts "===== Deleted #{invalid} invalid notifications\n"
      end

      desc "Removes any resources from search index that do not exist"
      task :searchable_resources, [] => :environment do
        puts "=== Deleting Searchable results\n"
        puts "==== Deleting invalid spaces \n"
        invalid = 0
        Decidim::SearchableResource.where.not(decidim_participatory_space_type: nil).find_each do |search|
          search.decidim_participatory_space
        rescue NameError
          search.destroy!
          invalid += 1
        end
        puts "===== Deleted #{invalid} invalid spaces\n"

        puts "==== Deleting invalid resources from search index \n"
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
        puts "===== Deleted #{invalid} invalid resources\n"
      end

      desc "Removes orphan categorizations"
      task fix_orphan_categorizations: :environment do
        logger = Logger.new($stdout)
        logger.info("Removing orphan categorizations...")

        Decidim::Categorization.find_each do |categorization|
          categorization.destroy if categorization.categorizable.nil?
        end
      end

      desc "Update all blocked users notifications_sending_frequency setting"
      task fix_blocked_user_notification: :environment do
        logger.info("=== Updating all blocked users notifications_sending_frequency ...")
        blocked_users = 0
        Decidim::User.blocked.where.not("notifications_sending_frequency = ?", "none").find_each do |blocked_user|
          unless blocked_user.notifications_sending_frequency == "none"
            blocked_user.update(notifications_sending_frequency: "none")
            blocked_users += 1
          end
        end
        logger.info("===== Updated #{blocked_users} blocked users")
      end

      def logger
        @logger ||= Logger.new($stdout)
      end
    end
  end
end
