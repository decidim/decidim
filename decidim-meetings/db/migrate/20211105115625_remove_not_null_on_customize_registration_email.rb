# frozen_string_literal: true

class RemoveNotNullOnCustomizeRegistrationEmail < ActiveRecord::Migration[6.0]
  def change
    change_column_null :decidim_meetings_meetings, :customize_registration_email, true
  end
end
