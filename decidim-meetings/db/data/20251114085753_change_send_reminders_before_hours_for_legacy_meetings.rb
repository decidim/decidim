# frozen_string_literal: true

class ChangeSendRemindersBeforeHoursForLegacyMeetings < ActiveRecord::Migration[7.2]
  class Meeting < ApplicationRecord
    self.table_name = "decidim_meetings_meetings"
  end

  def up
    Meeting.where(send_reminders_before_hours: nil).update_all(send_reminders_before_hours: 48) # rubocop:disable Rails/SkipsModelValidations
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
