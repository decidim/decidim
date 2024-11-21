# frozen_string_literal: true

module Decidim
  module Admin
    # A form object to select which users will be sent the selective newsletters
    class SelectiveNewsletterForm < Decidim::Form
      mimic :newsletter

      attribute :participatory_space_types, Array[SelectiveNewsletterParticipatorySpaceTypeForm]
      attribute :send_to_all_users, Boolean
      attribute :send_to_participants, Boolean
      attribute :send_to_followers, Boolean
      attribute :send_to_private_members, Boolean

      validates :send_to_all_users, presence: true, unless: lambda { |form|
        form.send_to_participants.present? ||
          form.send_to_followers.present? ||
          form.send_to_private_members.present?
      }
      validates :send_to_followers, presence: true, if: ->(form) { form.send_to_all_users.blank? && form.send_to_participants.blank? && form.send_to_private_members.blank? }
      validates :send_to_participants, presence: true, if: ->(form) { form.send_to_all_users.blank? && form.send_to_followers.blank? && form.send_to_private_members.blank? }
      validates :send_to_private_members, presence: true, if: ->(form) { form.send_to_all_users.blank? && form.send_to_followers.blank? && form.send_to_participants.blank? }

      validate :at_least_one_participatory_space_selected

      def map_model(_newsletter)
        self.participatory_space_types = Decidim.participatory_space_manifests.map do |manifest|
          SelectiveNewsletterParticipatorySpaceTypeForm.from_model(manifest:)
        end
      end

      private

      def at_least_one_participatory_space_selected
        return if send_to_all_users && current_user.admin?

        errors.add(:base, :at_least_one_space) if spaces_selected.blank?
      end

      def spaces_selected
        participatory_space_types.map do |type|
          spaces = type.ids.reject(&:empty?)
          [type.manifest_name, spaces] if spaces.present?
        end.compact
      end
    end
  end
end
