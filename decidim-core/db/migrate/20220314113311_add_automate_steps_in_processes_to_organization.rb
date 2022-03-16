# frozen_string_literal: true

class AddAutomateStepsInProcessesToOrganization < ActiveRecord::Migration[6.0]
  def change
    add_column :decidim_organizations,
               :automate_steps_in_processes,
               :boolean,
               default: false
  end
end
