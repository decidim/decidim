# frozen_string_literal: true

module Decidim
  module Admin
    # A form object to select which users will be sent the selective newsletters
    class SelectiveNewsletterForm < Decidim::Form
      mimic :newsletter

      attribute :participatory_space_types, Array[SelectiveNewsletterParticipatorySpaceTypeForm]
      attribute :verification_types, Array[String]
      attribute :send_to_all_users, Boolean
      attribute :send_to_verified_users, Boolean
      attribute :send_to_participants, Boolean
      attribute :send_to_followers, Boolean
      attribute :send_to_private_members, Boolean

      validates :send_to_all_users, presence: true, unless: :other_groups_selected_for_all_users?
      validates :send_to_verified_users, presence: true, unless: :other_groups_selected_for_verified_users?
      validates :send_to_followers, presence: true, if: :only_followers_selected?
      validates :send_to_participants, presence: true, if: :only_participants_selected?
      validates :send_to_private_members, presence: true, if: :only_private_members_selected?

      validate :at_least_one_participatory_space_selected

      def map_model(newsletter)
        self.participatory_space_types = Decidim.participatory_space_manifests.map do |manifest|
          SelectiveNewsletterParticipatorySpaceTypeForm.from_model(manifest:)
        end

        self.verification_types = newsletter.organization.available_authorizations
      end

      private

      def at_least_one_participatory_space_selected
        return if (send_to_all_users || send_to_verified_users) && current_user.admin?

        errors.add(:base, :at_least_one_space) if spaces_selected.blank?
      end

      def spaces_selected
        participatory_space_types.map do |type|
          spaces = type.ids.reject(&:empty?)
          [type.manifest_name, spaces] if spaces.present?
        end.compact
      end

      def other_groups_selected_for_all_users?
        send_to_verified_users.present? ||
          send_to_participants.present? ||
          send_to_followers.present? ||
          send_to_private_members.present?
      end

      def other_groups_selected_for_verified_users?
        send_to_all_users.present? ||
          send_to_participants.present? ||
          send_to_followers.present? ||
          send_to_private_members.present?
      end

      def only_followers_selected?
        send_to_all_users.blank? &&
          send_to_participants.blank? &&
          send_to_private_members.blank? &&
          send_to_verified_users.blank?
      end

      def only_participants_selected?
        send_to_all_users.blank? &&
          send_to_followers.blank? &&
          send_to_private_members.blank? &&
          send_to_verified_users.blank?
      end

      def only_private_members_selected?
        send_to_all_users.blank? &&
          send_to_followers.blank? &&
          send_to_participants.blank? &&
          send_to_verified_users.blank?
      end
    end
  end
end
