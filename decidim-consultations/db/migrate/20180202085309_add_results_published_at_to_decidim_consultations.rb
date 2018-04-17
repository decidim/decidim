# frozen_string_literal: true

class AddResultsPublishedAtToDecidimConsultations < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_consultations, :results_published_at, :date, index: true
  end
end
