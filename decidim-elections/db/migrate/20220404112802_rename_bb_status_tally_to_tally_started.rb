# frozen_string_literal: true

class RenameBbStatusTallyToTallyStarted < ActiveRecord::Migration[6.1]
  class Election < ApplicationRecord
    self.table_name = :decidim_elections_elections
  end

  def up
    # rubocop:disable Rails/SkipsModelValidations
    Election.where(bb_status: "tally").update_all(bb_status: "tally_started")
    # rubocop:enable Rails/SkipsModelValidations
  end

  def down
    # rubocop:disable Rails/SkipsModelValidations
    Election.where(bb_status: "tally_started").update_all(bb_status: "tally")
    # rubocop:enable Rails/SkipsModelValidations
  end
end
