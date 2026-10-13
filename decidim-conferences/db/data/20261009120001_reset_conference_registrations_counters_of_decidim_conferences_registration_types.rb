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
      # Lock the registration type row before counting and keep the lock until the counter is
      # written (data migrations run inside a transaction). Without the lock, a concurrent
      # counter-cache update on the same row could commit between the count and the write, and
      # this absolute write would overwrite it with a stale value.
      registration_type.lock!

      count = ConferenceRegistration.where(decidim_conference_registration_type_id: registration_type.id).count
      registration_type.update_column(:conference_registrations_count, count) # rubocop:disable Rails/SkipsModelValidations
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
