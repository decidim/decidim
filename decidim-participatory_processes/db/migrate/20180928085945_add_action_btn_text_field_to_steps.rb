# frozen_string_literal: true

class AddActionBtnTextFieldToSteps < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_participatory_process_steps, :action_btn_text, :jsonb
  end
end
