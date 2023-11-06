# frozen_string_literal: true

module Decidim
  module Admin
    class ParticipatorySpaceAdminUserForm < ParticipatorySpacePrivateUserForm
      attribute :role, String

      validates :role, presence: true
      validates :role, inclusion: { in: ParticipatorySpaceUser::ROLES }

      def roles
        ParticipatorySpaceUser::ROLES.map { |role| [I18n.t(role, scope:), role] }
      end
    end
  end
end
