# frozen_string_literal: true

class ResetConferenceRegistrationsCountersOfDecidimConferencesRegistrationTypes < ActiveRecord::Migration[8.1]
  # The outer transaction is disabled so every registration type is processed in its own
  # transaction and its row lock is released before the next type is processed.
  disable_ddl_transaction!

  class RegistrationType < ApplicationRecord
    self.table_name = :decidim_conferences_registration_types
  end

  class ConferenceRegistration < ApplicationRecord
    self.table_name = :decidim_conferences_conference_registrations
  end

  def up
    RegistrationType.find_each do |registration_type|
      # The count and the counter write share the same transaction, so the row lock is held until
      # the write is committed. Without the lock, a concurrent counter-cache update on the same row
      # could commit between the count and the write, and this absolute write would overwrite it
      # with a stale value. Committing per type also keeps the backfill re-runnable after a partial
      # failure, as every count is recomputed from the rows.
      registration_type.with_lock do
        count = ConferenceRegistration.where(decidim_conference_registration_type_id: registration_type.id).count
        registration_type.update_column(:conference_registrations_count, count) # rubocop:disable Rails/SkipsModelValidations
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
