# frozen_string_literal: true

class RemoveSupportsRequiredFromDecidimInitiativesTypes < ActiveRecord::Migration[5.1]
  def change
    remove_column :decidim_initiatives_types, :supports_required, :integer, null: false
  end
end
