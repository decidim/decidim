# frozen_string_literal: true

class AddFollowableCounterCacheToConsultations < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_consultations_questions, :follows_count, :integer, null: false, default: 0, index: true

    reversible do |dir|
      dir.up do
        Decidim::Consultations::Question.reset_column_information
        Decidim::Consultations::Question.find_each do |record|
          record.class.reset_counters(record.id, :follows)
        end
      end
    end
  end
end
