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
end
