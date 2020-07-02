# frozen_string_literal: true

module Decidim
  module Debates
    # This class holds a Form to create/update debates from Decidim's public views.
    class DebateForm < Decidim::Form
      include TranslatableAttributes

      attribute :title, String
      attribute :description, String
      attribute :category_id, Integer
      attribute :user_group_id, Integer
      attribute :debate, Debate

      validates :title, presence: true
      validates :description, presence: true
      validates :category, presence: true, if: ->(form) { form.category_id.present? }
      validate :editable_by_user

      def map_model(debate)
        super
        self.debate = debate

        # Debates can be translated in different languages from the admin but
        # the public form doesn't allow it. When a user creates a debate the
        # user locale is taken as the text locale.
        self.title = debate.title.values.first
        self.description = debate.description.values.first
        self.user_group_id = debate.decidim_user_group_id

        if debate.category.present?
          self.category_id = debate.category.id
          @category = debate.category
        end
      end

      def category
        @category ||= current_component.categories.find_by(id: category_id)
      end

      private

      def editable_by_user
        return unless debate.respond_to?(:editable_by?)

        errors.add(:debate, :invalid) unless debate.editable_by?(current_user)
      end
    end
  end
end
