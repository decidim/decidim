class AddQuestionTypeToSurveysQuestions < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_surveys_survey_questions, :question_type, :string
  end
end
