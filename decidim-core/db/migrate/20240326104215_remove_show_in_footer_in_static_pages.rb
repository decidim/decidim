# frozen_string_literal: true

class RemoveShowInFooterInStaticPages < ActiveRecord::Migration[6.1]
  def change
    remove_column :decidim_static_pages, :show_in_footer, :boolean
  end
end
