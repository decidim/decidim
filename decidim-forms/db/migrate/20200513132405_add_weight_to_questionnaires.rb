# frozen_string_literal: true

class AddWeightToQuestionnaires < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_forms_questionnaires, :weight, :integer, default: 0
  end
end
