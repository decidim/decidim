# frozen_string_literal: true

class ReindexSurveys < ActiveRecord::Migration[7.2]
  def up
    Decidim::Component.where(manifest_name: :surveys).published.find_each do |component|
      component.manifest.run_hooks(:publish, component)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
