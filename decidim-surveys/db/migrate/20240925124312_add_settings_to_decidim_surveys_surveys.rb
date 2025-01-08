# frozen_string_literal: true

class AddSettingsToDecidimSurveysSurveys < ActiveRecord::Migration[7.0]
  class Survey < ApplicationRecord
    include Decidim::HasComponent

    self.table_name = :decidim_surveys_surveys
  end

  def change
    reversible do |dir|
      dir.up do
        add_column :decidim_surveys_surveys, :starts_at, :datetime
        add_column :decidim_surveys_surveys, :ends_at, :datetime
        add_column :decidim_surveys_surveys, :announcement, :jsonb
        add_column :decidim_surveys_surveys, :allow_answers, :boolean
        add_column :decidim_surveys_surveys, :allow_unregistered, :boolean
        add_column :decidim_surveys_surveys, :clean_after_publish, :boolean
        add_column :decidim_surveys_surveys, :published_at, :datetime
        add_index :decidim_surveys_surveys, :published_at

        Survey.where(published_at: nil).find_each do |survey|
          published_at = survey.component.published_at
          next if published_at.nil?

          survey.update(published_at:)
        end
      end

      dir.down do
        remove_index :decidim_surveys_surveys, :published_at
        remove_column :decidim_surveys_surveys, :starts_at
        remove_column :decidim_surveys_surveys, :ends_at
        remove_column :decidim_surveys_surveys, :announcement
        remove_column :decidim_surveys_surveys, :allow_answers
        remove_column :decidim_surveys_surveys, :allow_unregistered
        remove_column :decidim_surveys_surveys, :clean_after_publish
        remove_column :decidim_surveys_surveys, :published_at
      end
    end
  end
end
