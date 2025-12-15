# frozen_string_literal: true

module Decidim
  module Admin
    module ParticipatorySpace
      # A form object used to create members from the
      # admin dashboard.
      #
      class MemberForm < Form
        include TranslatableAttributes

        mimic :member

        attribute :name, String
        attribute :email, String
        attribute :published, Boolean

        translatable_attribute :role, String

        validates :name, :email, presence: true

        validates :name, format: { with: UserBaseEntity::REGEXP_NAME }
      end
    end
  end
end
