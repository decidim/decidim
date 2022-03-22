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
    close_meeting_notif = Decidim::Meetings.close_meeting_notification
    close_meeting_reminder_notif = Decidim::Meetings.close_meeting_reminder_notification
    components = Decidim::Component.where(manifest_name: "meetings").published
    components.find_each do |component|
      send_notification(:first_notification, component, close_meeting_notif)
      send_notification(:reminder_notification, component, close_meeting_reminder_notif)
    end
  end

  private

  def send_notification(method, component, period)
    old_meetings = finder_query(component.id, period)
    space_admins = Decidim::ParticipatoryProcessUserRole.where(decidim_participatory_process_id: component.participatory_space_id, role: "admin").collect(&:user)
    space_admins = (global_admins + space_admins).uniq
    old_meetings.find_each do |meeting|
      authors = meeting.author.is_a?(Decidim::User) ? [meeting.author] : space_admins
      authors.each do |author|
        args = [meeting, author]
        send_notif = author.component_notification_settings.fetch("close_meeting_reminder", "1")
        # Send the notification
        Decidim::Meetings::CloseMeetingReminderMailer.send(method, *args).deliver_later if send_notif == "1"
      end
    end
  end

  def finder_query(component_id, period)
    Decidim::Meetings::Meeting
      .published
      .not_hidden
      .except_withdrawn
      .where(
        "decidim_component_id = ? AND end_time >= ? AND end_time <= ? AND closed_at IS NULL",
        component_id,
        period.days.ago.beginning_of_day,
        period.days.ago.end_of_day
      )
  end

  def global_admins
    @global_admins ||= Decidim::User.where(admin: true).all
  end
end
