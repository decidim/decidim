# frozen_string_literal: true

class AddQuestionnaireToExistingElections < ActiveRecord::Migration[5.2]
  class Election < ApplicationRecord
    self.table_name = :decidim_elections_elections

    has_one :questionnaire,
            class_name: "Questionnaire",
            dependent: :destroy,
            inverse_of: :questionnaire_for,
            as: :questionnaire_for
  end

  class Questionnaire < ApplicationRecord
    self.table_name = :decidim_forms_questionnaires

    belongs_to :questionnaire_for, polymorphic: true
  end

  def change
    Election.find_each do |election|
      next unless election.questionnaire

      election.update!(
        questionnaire: Questionnaire.new
      )
    end
  end
end
