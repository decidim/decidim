# frozen_string_literal: true

module Decidim
  module Debates
    # This class holds a Form to create/update debates from Decidim's public views.
    class DebateForm < Decidim::Form
      include TranslatableAttributes

      attribute :title, String
      attribute :description, String
      attribute :category_id, Integer
      attribute :scope_id, Integer
      attribute :user_group_id, Integer

      validates :title, presence: true
      validates :description, presence: true
      validates :category, presence: true, if: ->(form) { form.category_id.present? }
      validate :editable_by_user

      validates :scope_id, scope_belongs_to_component: true, if: ->(form) { form.scope_id.present? }

      def map_model(debate)
        super
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

      # Finds the Scope from the given scope_id, uses component scope if missing.
      #
      # Returns a Decidim::Scope
      def scope
        @scope ||= @attributes["scope_id"].value ? current_component.scopes.find_by(id: @attributes["scope_id"].value) : current_component.scope
      end

      # Scope identifier
      #
      # Returns the scope identifier related to the debate
      def scope_id
        super || scope&.id
      end

      def debate
        @debate ||= Debate.find_by(id:)
      end

      private

      def editable_by_user
        return unless debate.respond_to?(:editable_by?)

        errors.add(:debate, :invalid) unless debate.editable_by?(current_user)
      end
    end
  end
end
