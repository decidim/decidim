# frozen_string_literal: true

module Decidim
  # A UserGroupMembership associate user with user groups
  class ParticipatoryProcessUser < ApplicationRecord
    belongs_to :user, class_name: "Decidim::User", foreign_key: :decidim_user_id
    belongs_to :participatory_process, class_name: "Decidim::ParticipatoryProcess", foreign_key: :decidim_participatory_process_id
  end
end
