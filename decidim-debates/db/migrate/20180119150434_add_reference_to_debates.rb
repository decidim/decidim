# frozen_string_literal: true

class AddReferenceToDebates < ActiveRecord::Migration[5.1]
  class Debate < ApplicationRecord
    self.table_name = :decidim_debates_debates
  end

  def change
    add_column :decidim_debates_debates, :reference, :string
    Debate.find_each(&:touch)
  end
end
