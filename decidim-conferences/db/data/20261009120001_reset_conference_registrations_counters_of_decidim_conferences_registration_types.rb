# frozen_string_literal: true

class ResetConferenceRegistrationsCountersOfDecidimConferencesRegistrationTypes < ActiveRecord::Migration[8.1]
  class RegistrationType < ApplicationRecord
    self.table_name = :decidim_conferences_registration_types
  end

  class ConferenceRegistration < ApplicationRecord
    self.table_name = :decidim_conferences_conference_registrations
  end

  def up
    RegistrationType.find_each do |registration_type|
      registration_type.update_column( # rubocop:disable Rails/SkipsModelValidations
        :conference_registrations_count,
        ConferenceRegistration.where(decidim_conference_registration_type_id: registration_type.id).count
      )
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
