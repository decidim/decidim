# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A form object used to invite users to join a conference.
      #
      class ConferenceRegistrationInviteForm < Form
        include TranslatableAttributes
        attribute :name, String
        attribute :email, String
        attribute :user_id, Integer
        attribute :registration_type_id, Integer
        attribute :existing_user, Boolean, default: false

        validates :name, presence: true, unless: proc { |object| object.existing_user }
        validates :email, presence: true, "valid_email_2/email": { disposable: true }, unless: proc { |object| object.existing_user }
        validates :user, presence: true, if: proc { |object| object.existing_user }

        def user
          @user ||= current_organization.users.find_by(id: user_id)
        end

        def registration_type
          @registration_type ||= current_participatory_space.registration_types.find_by(id: registration_type_id)
        end

        def registration_types_for_select
          @registration_types_for_select ||= current_participatory_space.registration_types&.map do |registration_type|
            [
              translated_attribute(registration_type.title),
              registration_type.id
            ]
          end
        end
      end
    end
  end
end
