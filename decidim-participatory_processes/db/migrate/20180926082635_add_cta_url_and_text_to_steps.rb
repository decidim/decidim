# frozen_string_literal: true

class AddCtaUrlAndTextToSteps < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_participatory_process_steps, :cta_text, :jsonb
    add_column :decidim_participatory_process_steps, :cta_path, :string
  end
end
