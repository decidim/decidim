# frozen_string_literal: true

class ResetNegativeChildrenCountCounters < ActiveRecord::Migration[5.2]
  class Assembly < ApplicationRecord
    self.table_name = :decidim_assemblies
  end

  def change
    ids = Assembly.unscoped.where("children_count < 0").pluck(:id)
    ids.each { |id| Assembly.unscoped.reset_counters(id, :children_count) }
  end
end
