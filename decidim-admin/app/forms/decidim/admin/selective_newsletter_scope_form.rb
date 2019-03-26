# frozen_string_literal: true

module Decidim
  module Admin
    class SelectiveNewsletterScopeForm < Form
      mimic :scope

      attribute :name, String
      attribute :checked, Boolean
      attribute :children, Array[SelectiveNewsletterScopeForm]

      def map_model(model_hash)
        scope = model_hash[:scope]
        newsletter = model_hash[:newsletter]

        self.id = scope.id
        self.name = scope.name
        self.checked = newsletter.sent_scopes_ids.include?(scope.id)
        self.children = scope.children.map do |children_scope|
          SelectiveNewsletterScopeForm.from_model(scope: children_scope, newsletter: newsletter)
        end
      end
    end
  end
end
