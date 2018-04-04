# frozen_string_literal: true

class AddVotesCountToDecidimConsultationsQuestion < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_consultations_questions, :votes_count, :integer, null: false, default: 0
  end
end
