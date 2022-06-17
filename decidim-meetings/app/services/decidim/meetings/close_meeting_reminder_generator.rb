# frozen_string_literal: true

module Decidim
  module Meetings
    # This class is the generator class which creates and updates meetings related reminders,
    # after reminder is generated it is send to user who have not closed past meetings.
    class CloseMeetingReminderGenerator
      attr_reader :reminder_jobs_queued

      def initialize
        @reminder_manifest = Decidim.reminders_registry.for(:close_meeting)
        @reminder_jobs_queued = 0
      end

      # Creates reminders and updates them if they already exists.
      def generate
        Decidim::Component.where(manifest_name: "meetings").published.each do |component|
          send_reminders(component)
        end
      end

      private

      attr_reader :reminder_manifest

      def finder_query(component_id, interval)
        Decidim::Meetings::Meeting
          .published
          .not_hidden
          .except_withdrawn
          .where(
            "decidim_component_id = ? AND end_time >= ? AND end_time <= ? AND closed_at IS NULL",
            component_id,
            interval.ago.beginning_of_day,
            interval.ago.end_of_day
          )
      end

      def send_reminders(component)
        intervals = Array(reminder_manifest.settings.attributes[:reminder_times].default)
        space_admins = Decidim::ParticipatoryProcessUserRole.where(decidim_participatory_process_id: component.participatory_space_id, role: "admin").collect(&:user)
        space_admins = (global_admins + space_admins).uniq
        intervals.each do |interval|
          finder_query(component.id, interval).find_each do |meeting|
            authors = meeting.official? ? space_admins : [meeting.author]
            authors.each do |author|
              send_notif = author.notification_settings.fetch("close_meeting_reminder", "1")
              next unless send_notif == "1"

              reminder = Decidim::Reminder.find_or_create_by(user: author, component:)
              record = Decidim::ReminderRecord.find_or_create_by(reminder:, remindable: meeting)
              record.update(state: "active") unless record.active?
              reminder.records << record
              reminder.save!

              Decidim::Meetings::SendCloseMeetingReminderJob.perform_later(record)
              @reminder_jobs_queued += 1
            end
          end
        end
      end

      def global_admins
        @global_admins ||= Decidim::User.where(admin: true).all
      end
    end
  end
end
