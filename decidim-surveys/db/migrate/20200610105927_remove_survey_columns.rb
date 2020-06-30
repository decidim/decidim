# frozen_string_literal: true

class RemoveSurveyColumns < ActiveRecord::Migration[5.2]
  def change
    remove_column :decidim_surveys_surveys, :title if ActiveRecord::Base.connection.column_exists?(:decidim_surveys_surveys, :title)
    remove_column :decidim_surveys_surveys, :description if ActiveRecord::Base.connection.column_exists?(:decidim_surveys_surveys, :description)
    remove_column :decidim_surveys_surveys, :tos if ActiveRecord::Base.connection.column_exists?(:decidim_surveys_surveys, :tos)
    remove_column :decidim_surveys_surveys, :published_at if ActiveRecord::Base.connection.column_exists?(:decidim_surveys_surveys, :published_at)
  end
end
