# frozen_string_literal: true

class RemoveResultProgressUpdatedNotification < ActiveRecord::Migration[5.2]
  def change
    Decidim::Notification.where(event_name: "decidim.events.accountability.result_progress_updated").delete_all
  end
end
