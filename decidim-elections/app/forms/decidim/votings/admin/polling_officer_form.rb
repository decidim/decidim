# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      class PollingOfficerForm < Decidim::Form
        attribute :name, String
        attribute :email, String
        attribute :user_id, Integer
        attribute :existing_user, Boolean, default: false

        validates :email, presence: true, format: { with: ::Devise.email_regexp }, unless: ->(form) { form.existing_user }
        validates :name, presence: true, format: { with: UserBaseEntity::REGEXP_NAME }, unless: ->(form) { form.existing_user }
        validates :user, presence: true, if: ->(form) { form.existing_user }

        def map_model(model)
          self.user_id = model.decidim_user_id
          self.existing_user = user_id.present?
        end

        def user
          @user ||= current_organization.users.find_by(id: user_id)
        end
      end
    end
  end
end
