# frozen_string_literal: true

class FixGidLeakingInMeetingTitles < ActiveRecord::Migration[7.0]
  class User < ApplicationRecord
    self.table_name = :decidim_users
  end

  class Meeting < ApplicationRecord
    self.table_name = :decidim_meetings_meetings
  end

  GLOBAL_ID_REGEX = %r{gid://[\w-]+/Decidim::User/(\d+)}

  def up
    Meeting.find_each do |meeting|
      next if meeting.title.blank?

      updated_title = fix_gid_in_translatable_attribute(meeting.title)
      next if updated_title == meeting.title

      meeting.update_column(:title, updated_title) # rubocop:disable Rails/SkipsModelValidations
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def fix_gid_in_translatable_attribute(translatable_value)
    return translatable_value unless translatable_value.is_a?(Hash)

    translatable_value.transform_values do |value|
      next value unless value.is_a?(String)

      value.gsub(GLOBAL_ID_REGEX) do |match|
        user_id = Regexp.last_match(1)
        nickname = User.where(id: user_id).pick(:nickname)
        nickname ? "@#{nickname}" : match
      end
    end
  end
end
