class AddDeleteAnswersOnPublishToSurveys < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_surveys_surveys, :delete_answers_on_publish, :boolean, default: false
  end
end
