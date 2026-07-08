# frozen_string_literal: true

module Decidim
  module Admin
    class ParticipatorySpaceAdminUserForm < Decidim::Admin::ParticipatorySpace::MemberForm
      attribute :role, String

      attribute :member_type, String, default: "email"

      validates :role, presence: true
      validates :role, inclusion: { in: ParticipatorySpaceUser::ROLES }
      validates :name, format: { with: Decidim::UserBaseEntity::REGEXP_NAME }

      def roles
        ParticipatorySpaceUser::ROLES.map { |role| [I18n.t(role, scope:), role] }
      end
    end
  end
end
