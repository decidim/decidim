# frozen_string_literal: true

module Decidim
  module Admin
    # The form that validates the data to construct a valid Newsletter.
    class SelectiveNewsletterForm < Decidim::Form
      mimic :newsletter

      attribute :participatory_space_types, Array[SelectiveNewsletterParticipatorySpaceTypeForm]
      attribute :scope_ids, Array
      attribute :send_to_all_users, Boolean, default: true
      attribute :send_to_participants, Boolean
      attribute :send_to_followers, Boolean

      validates :send_to_all_users, presence: true, unless: ->(form) { form.send_to_participants.present? || form.send_to_followers.present? }
      validates :send_to_followers, presence: true, if: ->(form) { !form.send_to_all_users.present? && !form.send_to_participants.present?}
      validates :send_to_participants, presence: true, if: ->(form) { !form.send_to_all_users.present? && !form.send_to_followers.present? }

      validate :atleast_one_participatory_space_selected

      def map_model(newsletter)
        self.participatory_space_types = Decidim.participatory_space_manifests.map do |manifest|
          SelectiveNewsletterParticipatorySpaceTypeForm.from_model(manifest: manifest)
        end
      end

      private

      def atleast_one_participatory_space_selected
        return if send_to_all_users && current_user.admin?
        errors.add(:base, "Select atleast one participatory space") if spaces_selected.blank?
      end

      def spaces_selected
        participatory_space_types.map do |type|
          spaces = type.ids.reject{|e| e.empty?}
          [type.manifest_name, spaces] unless spaces.blank?
        end.compact
      end
    end
  end
end
