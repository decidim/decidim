# frozen_string_literal: true

class AddColumnsToPages < ActiveRecord::Migration[5.2]
  class StaticPage < ApplicationRecord
    self.table_name = :decidim_static_pages
  end

  # rubocop:disable Rails/SkipsModelValidations
  def change
    change_table :decidim_static_pages do |t|
      t.column :weight, :integer, default: nil, null: true
      t.column :show_in_footer, :boolean, default: false, null: false
    end

    Decidim::StaticPage.where(
      slug: ["faq", "terms-and-conditions", "accessibility"]
    ).update_all(show_in_footer: true)
    # rubocop:enable Rails/SkipsModelValidations
  end
end
