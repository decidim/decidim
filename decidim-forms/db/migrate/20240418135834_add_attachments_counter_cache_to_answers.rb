# frozen_string_literal: true

class AddAttachmentsCounterCacheToAnswers < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_forms_answers, :attachments_count, :integer, null: false, default: 0

    reversible do |dir|
      dir.up do
        Decidim::Forms::Answer.reset_column_information
        Decidim::Forms::Answer.find_each do |record|
          record.class.reset_counters(record.id, :attachments)
        end
      end
    end
  end
end
