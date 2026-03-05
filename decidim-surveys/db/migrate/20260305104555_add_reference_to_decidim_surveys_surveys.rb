# frozen_string_literal: true

class AddReferenceToDecidimSurveysSurveys < ActiveRecord::Migration[8.0]
  def change
    add_column :decidim_surveys_surveys, :reference, :string
  end
end
