# frozen_string_literal: true

class AddWeightFieldToConsultations < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_consultations, :weight, :integer, null: false, default: 0
  end
end
