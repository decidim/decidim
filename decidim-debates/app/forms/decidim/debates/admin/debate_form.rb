# frozen_string_literal: true

module Decidim
  module Debates
    module Admin
      # This class holds a Form to create/update debates from Decidim's admin panel.
      class DebateForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :title, String
        translatable_attribute :description, String
        translatable_attribute :instructions, String
        translatable_attribute :information_updates, String
        attribute :start_time, Decidim::Attributes::TimeWithZone
        attribute :end_time, Decidim::Attributes::TimeWithZone
        attribute :decidim_category_id, Integer
        attribute :finite, Boolean, default: true
        attribute :scope_id, Integer
        attribute :comments_enabled, Boolean, default: true

        validates :title, translatable_presence: true
        validates :description, translatable_presence: true
        validates :instructions, translatable_presence: true
        validates :start_time, presence: { if: :validate_start_time? }, date: { before: :end_time, allow_blank: true, if: :validate_start_time? }
        validates :end_time, presence: { if: :validate_end_time? }, date: { after: :start_time, allow_blank: true, if: :validate_end_time? }

        validates :category, presence: true, if: ->(form) { form.decidim_category_id.present? }
        validates :scope, presence: true, if: ->(form) { form.scope_id.present? }
        validates :scope_id, scope_belongs_to_component: true, if: ->(form) { form.scope_id.present? }

        def map_model(model)
          self.finite = model.start_time.present? && model.end_time.present?
          self.decidim_category_id = model.categorization.decidim_category_id if model.categorization
          presenter = DebatePresenter.new(model)

          self.title = presenter.title(all_locales: title.is_a?(Hash))
          self.description = presenter.description(all_locales: description.is_a?(Hash))
        end

        def category
          return unless current_component

          @category ||= current_component.categories.find_by(id: decidim_category_id)
        end

        # Finds the Scope from the given decidim_scope_id, uses the compoenent scope if missing.
        #
        # Returns a Decidim::Scope
        def scope
          @scope ||= @attributes["scope_id"].value ? current_component.scopes.find_by(id: @attributes["scope_id"].value) : current_component.scope
        end

        # Scope identifier
        #
        # Returns the scope identifier related to the meeting
        def scope_id
          super || scope&.id
        end

        private

        def validate_end_time?
          finite && start_time.present?
        end

        def validate_start_time?
          end_time.present?
        end
      end
    end
  end
end
