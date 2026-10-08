# frozen_string_literal: true

class FixGidLeakingInProposalTitles < ActiveRecord::Migration[7.0]
  class User < ApplicationRecord
    self.table_name = :decidim_users
  end

  class Proposal < ApplicationRecord
    self.table_name = :decidim_proposals_proposals
  end

  GLOBAL_ID_REGEX = %r{gid://[\w-]+/Decidim::User/(\d+)}

  def up
    Proposal.find_each do |proposal|
      next if proposal.title.blank?

      updated_title = fix_gid_in_translatable_attribute(proposal.title)
      next if updated_title == proposal.title

      proposal.update_column(:title, updated_title) # rubocop:disable Rails/SkipsModelValidations
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
