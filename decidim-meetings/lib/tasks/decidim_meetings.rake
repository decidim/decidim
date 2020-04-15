# frozen_string_literal: true

namespace :decidim_meetings do
  # For privacy reasons we recommend that you delete this registration form when you no longer need it.
  # By default this is 3 months after the meeting has passed
  desc "Remove registration forms belonging to meetings that have ended more than X months ago"
  task :clean_registration_forms, [:months] => :environment do |_t, args|
    args.with_defaults(months: 3)

    old_meetings = Decidim::Meetings::Meeting.past.where(Decidim::Meetings::Meeting.arel_table[:end_time].lteq(Time.current - args[:months]))
    Decidim::Forms::Questionnaire.where(questionnaire_for: old_meetings).destroy_all
  end
end
