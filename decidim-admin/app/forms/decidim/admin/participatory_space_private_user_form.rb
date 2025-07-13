# frozen_string_literal: true

module Decidim
  module Admin
    # A form object used to create participatory space private users from the
    # admin dashboard.
    #
    class ParticipatorySpacePrivateUserForm < Form
      include TranslatableAttributes

      mimic :participatory_space_private_user

      attribute :name, String
      attribute :email, String
      attribute :published, Boolean

      translatable_attribute :role, String

      validates :name, :email, presence: true

      validates :name, format: { with: UserBaseEntity::REGEXP_NAME }
    end
  end
end
