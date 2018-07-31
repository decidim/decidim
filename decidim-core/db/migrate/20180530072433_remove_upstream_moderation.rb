# frozen_string_literal: true

class RemoveUpstreamModeration < ActiveRecord::Migration[5.1]
  def change
    remove_column :decidim_moderations, :upstream_moderation, :string

    Decidim::Moderation.all.map { |m| m.destroy if m.report_count.zero? }
  end
end
