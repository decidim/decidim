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
        attribute :member_type, String, default: "name"
        attribute :published, Boolean

        translatable_attribute :role, String

        validates :member_type, presence: true, inclusion: { in: %w(name email) }
        validates :user, presence: true, if: proc { |object| object.member_type == "name" }
        validates :email, presence: true, "valid_email_2/email": { disposable: true },
                          if: proc { |object| object.member_type == "email" }

        def user
          @user ||= current_organization.users.find_by(id: user_id)
        end
      end
    end
  end
end
