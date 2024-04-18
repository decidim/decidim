# frozen_string_literal: true

class AddAttachmentsCounterCacheToPosts < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_blogs_posts, :attachments_count, :integer, null: false, default: 0

    reversible do |dir|
      dir.up do
        Decidim::Blogs::Post.reset_column_information
        Decidim::Blogs::Post.find_each do |record|
          record.class.reset_counters(record.id, :attachments)
        end
      end
    end
  end
end
