# frozen_string_literal: true

class AddValueToDecidimFormsResponses < ActiveRecord::Migration[8.1]
  def change
    add_column :decidim_forms_responses, :value, :jsonb
  end
end
