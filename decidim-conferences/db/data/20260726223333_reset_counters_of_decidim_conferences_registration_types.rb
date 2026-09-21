# frozen_string_literal: true

class ResetCountersOfDecidimConferencesRegistrationTypes < ActiveRecord::Migration[8.1]
  def up
    Decidim::Conferences::RegistrationType.find_each do |registration|
      Decidim::Conferences::RegistrationType.reset_counters(registration.id, :conference_meeting_registration_types)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
