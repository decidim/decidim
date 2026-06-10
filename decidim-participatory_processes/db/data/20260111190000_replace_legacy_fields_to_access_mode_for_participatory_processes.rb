# frozen_string_literal: true

class ReplaceLegacyFieldsToAccessModeForParticipatoryProcesses < ActiveRecord::Migration[7.2]
  def up
    say_with_time "Backfilling participatory_processes access_mode from legacy flag" do
      Decidim::ParticipatoryProcess.reset_column_information
      Decidim::ParticipatoryProcess.find_each do |process|
        mode = process.private_space ? :restricted : :open
        process.write_attribute(:access_mode, Decidim::ParticipatoryProcess.access_modes[mode])
        process.save!(validate: false)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
