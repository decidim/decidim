# frozen_string_literal: true

class ReplaceLegacyFieldsToAccessModeForAssemblies < ActiveRecord::Migration[7.2]
  def up
    say_with_time "Backfilling assemblies access_mode from legacy flags" do
      Decidim::Assembly.reset_column_information
      Decidim::Assembly.find_each do |assembly|
        mode = if assembly.private_space && !assembly.is_transparent
                 :restricted
               elsif assembly.private_space && assembly.is_transparent
                 :transparent
               else
                 :open
               end
        # Use write_attribute to avoid validations/callbacks
        assembly.write_attribute(:access_mode, Decidim::Assembly.access_modes[mode])
        assembly.save!(validate: false)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
