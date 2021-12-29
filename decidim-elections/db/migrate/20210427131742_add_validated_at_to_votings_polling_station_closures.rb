# frozen_string_literal: true

class AddValidatedAtToVotingsPollingStationClosures < ActiveRecord::Migration[6.0]
  def change
    add_column :decidim_votings_polling_station_closures, :validated_at, :date
    add_column :decidim_votings_polling_station_closures, :monitoring_committee_notes, :string
  end
end
