# frozen_string_literal: true

class AddUndoOnlineSignaturesEnabledToInitiativesTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_initiatives_types, :undo_online_signatures_enabled, :boolean, null: false, default: true
  end
end
