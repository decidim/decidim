class CreateDecidimSurveys < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_surveys_surveys do |t|
      t.jsonb :title
      t.jsonb :description
      t.jsonb :toc
      t.references :decidim_feature, index: true

      t.timestamps
    end
  end
end
