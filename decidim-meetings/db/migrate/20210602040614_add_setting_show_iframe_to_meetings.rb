# frozen_string_literal: true

class AddSettingShowIframeToMeetings < ActiveRecord::Migration[6.0]
  def change
    add_column :decidim_meetings_meetings, :show_iframe, :boolean, default: false
  end
end
