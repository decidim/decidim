# frozen_string_literal: true

class AddVotingsPollingStationReferencesToVotingsPollingOfficer < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_votings_polling_officers, :managed_polling_station_id, :integer
    add_column :decidim_votings_polling_officers, :presided_polling_station_id, :integer
  end
end
