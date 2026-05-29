# frozen_string_literal: true

class AddReferenceToDecidimPagesPages < ActiveRecord::Migration[8.0]
  class Page < ApplicationRecord
    self.table_name = :decidim_pages_pages

    include Decidim::HasComponent
    include Decidim::HasReference
  end

  def change
    add_column :decidim_pages_pages, :reference, :string
    Page.reset_column_information
    Page.find_each { |page| page.send(:store_reference) }
  end
end
