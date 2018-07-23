# frozen_string_literal: true

class AddFreeTextToFormsAnswerOptions < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_forms_answer_options, :free_text, :boolean
  end
end
