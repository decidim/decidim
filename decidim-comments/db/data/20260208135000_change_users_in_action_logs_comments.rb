# frozen_string_literal: true

class ChangeUsersInActionLogsComments < ActiveRecord::Migration[7.2]
  class ActionLog < ApplicationRecord
    self.table_name = :decidim_action_logs

    belongs_to :user, class_name: "Decidim::UserBaseEntity"

    belongs_to :resource,
               polymorphic: true,
               optional: true
  end

  def up
    ActionLog.where(resource_type: "Decidim::Comments::Comment").find_each do |action_log|
      next unless action_log.resource

      author = action_log.resource.author

      next unless author.is_a?(Decidim::User)
      next unless author.group?

      action_log.user_id = author.id
      action_log.extra["user"] ||= {}
      action_log.extra["user"].merge!("name" => author.name, "nickname" => author.nickname)
      action_log.save!
    end
  end
end
