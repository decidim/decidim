# frozen_string_literal: true

namespace :decidim_meetings do
  # For privacy reasons we recommend that you delete this registration form when you no longer need it.
  # By default this is 3 months after the meeting has passed
  desc "Remove registration forms belonging to meetings that have ended more than X months ago"
  task :clean_registration_forms, [:months] => :environment do |_t, args|
    args.with_defaults(months: 3)

    query = Decidim::Meetings::Meeting.arel_table[:end_time].lteq(Time.current - args[:months].months)
    old_meeting_ids = Decidim::Meetings::Meeting.where(query).pluck(:id)
    old_questionnaires = Decidim::Forms::Questionnaire.where(questionnaire_for_type: "Decidim::Meetings::Meeting", questionnaire_for_id: old_meeting_ids)

    old_questionnaires.destroy_all
  end

  desc "Send initial and reminder notifications to users whose events have passed"
  task close_meeting_notification: :environment do

    components = Decidim::Component.where(manifest_name: "meetings").published
    components.each do |component|
      enable_initial_notif = component.settings.enable_cr_initial_notifications
      close_report_notif = component.settings.close_report_notifications
      enable_reminder_notif = component.settings.enable_cr_reminder_notifications
      close_report_reminder_notif = component.settings.close_report_reminder_notifications

      component_id = component.id
      send_first_notification(component_id, close_report_notif) if enable_initial_notif
      send_reminder_notification(component_id, close_report_reminder_notif) if enable_reminder_notif
    end
  end

  private

  def send_first_notification(component_id, period)
    old_meetings = finder_query(component_id, period)
    old_meetings.find_each do |meeting|
      next unless meeting.author.is_a?(Decidim::User)
      puts "initial"
      puts meeting.id
      # Send the notification
      Decidim::Meetings::CloseMeetingReminderMailer.first_notification(meeting, meeting.author).deliver_now
    end
  end

  def send_reminder_notification(component_id, period)
    old_meetings = finder_query(component_id, period)
    old_meetings.find_each do |meeting|
      next unless meeting.author.is_a?(Decidim::User)
      puts "reminder"
      puts meeting.id
      # Send the notification
      Decidim::Meetings::CloseMeetingReminderMailer.reminder_notification(meeting, meeting.author).deliver_now
    end
  end

  def finder_query(component_id, period)
    Decidim::Meetings::Meeting.
      published.
      except_withdrawn.
      where(
        "decidim_component_id = ? AND end_time >= ? AND end_time <= ? AND closed_at IS NULL",
        component_id,
        period.days.ago.beginning_of_day,
        period.days.ago.end_of_day
      )
  end
end
