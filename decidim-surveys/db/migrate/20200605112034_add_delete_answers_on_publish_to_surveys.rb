# frozen_string_literal: true

class AddDeleteAnswersOnPublishToSurveys < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_surveys_surveys, :clean_after_publish, :boolean, default: false
  end
end
