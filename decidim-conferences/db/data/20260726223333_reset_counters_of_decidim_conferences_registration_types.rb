# frozen_string_literal: true

class ResetCountersOfDecidimConferencesRegistrationTypes < ActiveRecord::Migration[8.1]
  class RegistrationType < ApplicationRecord
    self.table_name = :decidim_conferences_registration_types
  end

  class ConferenceMeetingRegistrationType < ApplicationRecord
    self.table_name = :decidim_conferences_conference_meeting_registration_types
  end

  def up
    RegistrationType.find_each do |registration_type|
      registration_type.update_column( # rubocop:disable Rails/SkipsModelValidations
        :conference_meeting_registration_types_count,
        ConferenceMeetingRegistrationType.where(registration_type_id: registration_type.id).count
      )
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
