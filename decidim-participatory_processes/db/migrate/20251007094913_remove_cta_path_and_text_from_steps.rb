# frozen_string_literal: true

class RemoveCtaPathAndTextFromSteps < ActiveRecord::Migration[7.2]
  def change
    remove_column :decidim_participatory_process_steps, :cta_text, :jsonb
    remove_column :decidim_participatory_process_steps, :cta_path, :string
  end
end
