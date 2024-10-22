# frozen_string_literal: true

class AddSettingsToDecidimSurveysSurveys < ActiveRecord::Migration[7.0]
  class Survey < ApplicationRecord
    self.table_name = :decidim_surveys_surveys
  end

  def up
    add_column :decidim_surveys_surveys, :starts_at, :datetime
    add_column :decidim_surveys_surveys, :ends_at, :datetime
    add_column :decidim_surveys_surveys, :announcement, :jsonb
    add_column :decidim_surveys_surveys, :allow_answers, :boolean
    add_column :decidim_surveys_surveys, :allow_unregistered, :boolean
    add_column :decidim_surveys_surveys, :clean_after_publish, :boolean
    add_column :decidim_surveys_surveys, :published_at, :datetime, index: true

    Survey.update(published_at: Time.current)
  end

  def down
    remove_column :decidim_surveys_surveys, :starts_at
    remove_column :decidim_surveys_surveys, :ends_at
    remove_column :decidim_surveys_surveys, :announcement
    remove_column :decidim_surveys_surveys, :allow_answers
    remove_column :decidim_surveys_surveys, :allow_unregistered
    remove_column :decidim_surveys_surveys, :clean_after_publish
    remove_column :decidim_surveys_surveys, :published_at
  end
end
