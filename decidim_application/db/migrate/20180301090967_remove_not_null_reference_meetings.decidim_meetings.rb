# This migration comes from decidim_meetings (originally 20170410074252)
# frozen_string_literal: true

class RemoveNotNullReferenceMeetings < ActiveRecord::Migration[5.0]
  def change
    change_column_null :decidim_meetings_meetings, :reference, true
  end
end
