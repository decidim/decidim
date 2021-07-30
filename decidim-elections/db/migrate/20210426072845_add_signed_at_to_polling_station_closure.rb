# frozen_string_literal: true

class AddSignedAtToPollingStationClosure < ActiveRecord::Migration[6.0]
  def change
    add_column :decidim_votings_polling_station_closures, :signed_at, :date
  end
end
