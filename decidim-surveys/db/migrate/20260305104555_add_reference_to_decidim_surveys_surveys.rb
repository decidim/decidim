# frozen_string_literal: true

class AddReferenceToDecidimSurveysSurveys < ActiveRecord::Migration[8.0]
  class Survey < ApplicationRecord
    self.table_name = :decidim_surveys_surveys

    include Decidim::HasComponent
    include Decidim::HasReference
  end

  def change
    add_column :decidim_surveys_surveys, :reference, :string
    Survey.reset_column_information
    Survey.find_each { |survey| survey.send(:store_reference) }
  end
end
