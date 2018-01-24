# frozen_string_literal: true

module Decidim
  # A UserGroupMembership associate user with user groups
  class AssemblyUser < ApplicationRecord
    belongs_to :user, class_name: "Decidim::User", foreign_key: :decidim_user_id
    belongs_to :assembly, class_name: "Decidim::Assembly", foreign_key: :decidim_assembly_id
  end
end
