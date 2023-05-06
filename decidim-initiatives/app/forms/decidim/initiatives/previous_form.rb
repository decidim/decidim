# frozen_string_literal: true

module Decidim
  module Initiatives
    # A form object used to collect the title and description for an initiative.
    class PreviousForm < Form
      include TranslatableAttributes

      mimic :initiative

      attribute :title, String
      attribute :description, String
      attribute :type_id, Integer
      attribute :scope_id, Integer

      validates :title, :description, presence: true
      validates :title, length: { maximum: 150 }
      validates :type_id, presence: true
      validate :scope_exists

      def type
        @type ||= type_id ? Decidim::InitiativesType.find(type_id) : context.initiative.type
      end

      def scope
        @scope ||= Scope.find(scope_id) if scope_id.present?
      end

      def scope_id
        return nil if type.only_global_scope_enabled?

        super.presence
      end

      def available_scopes
        @available_scopes ||= if type.only_global_scope_enabled?
                                type.scopes.where(scope: nil)
                              else
                                type.scopes
                              end
      end

      private

      def scope_exists
        return if scope_id.blank?

        errors.add(:scope_id, :invalid) unless InitiativesTypeScope.exists?(type:, scope:)
      end
    end
  end
end
