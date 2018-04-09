# frozen_string_literal: true

class AddIFrameUrlToDecidimConsultationsQuestions < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_consultations_questions, :i_frame_url, :string
    add_column :decidim_consultations_questions, :external_voting, :boolean
  end
end
