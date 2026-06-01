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
        attribute :user_id, Integer
        attribute :existing_user, Boolean, default: false
        attribute :published, Boolean

        translatable_attribute :role, String

        validates :name, presence: true, unless: proc { |object| object.existing_user }
        validates :email, presence: true, "valid_email_2/email": { disposable: true }, unless: proc { |object| object.existing_user }
        validates :user, presence: true, if: proc { |object| object.existing_user }

        validates :name, format: { with: UserBaseEntity::REGEXP_NAME }, unless: proc { |object| object.existing_user }

        def user
          @user ||= current_organization.users.find_by(id: user_id)
        end
      end
    end
  end
end
