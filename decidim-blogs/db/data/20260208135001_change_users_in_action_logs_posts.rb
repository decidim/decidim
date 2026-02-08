# frozen_string_literal: true

class ChangeUsersInActionLogsPosts < ActiveRecord::Migration[7.2]
  class ActionLog < ApplicationRecord
    self.table_name = :decidim_action_logs

    belongs_to :user, class_name: "Decidim::UserBaseEntity"

    belongs_to :resource,
               polymorphic: true,
               optional: true
  end

  class Post < ApplicationRecord
    self.table_name = :decidim_blogs_posts

    belongs_to :author, polymorphic: true, foreign_key: "decidim_author_id", foreign_type: "decidim_author_type"
  end

  def up
    ActionLog.where(resource_type: "Decidim::Blogs::Post").find_each do |action_log|
      author = action_log.resource.author

      next unless author.is_a?(Decidim::User)
      next unless author.group?

      action_log.user_id = author.id
      action_log.extra["user"].merge!("name" => author.name, :nickname => author.nickname)
      action_log.save!
    end
  end
end
