# frozen_string_literal: true

module Decidim
  module Initiatives
    # A form object used to collect the data for a new initiative.
    class InitiativeForm < Form
      include TranslatableAttributes

      mimic :initiative

      attribute :title, String
      attribute :description, String
      attribute :type_id, Integer
      attribute :scope_id, Integer
      attribute :decidim_user_group_id, Integer
      attribute :signature_type, String
      attribute :state, String

      validates :title, :description, presence: true
      validates :title, length: { maximum: 150 }
      validates :signature_type, presence: true
      validates :type_id, presence: true
      validate :scope_exists

      def map_model(model)
        self.type_id = model.type.id
        self.scope_id = model.scope&.id
      end

      def signature_type_updatable?
        state == "created" || state.nil?
      end

      def scope_id
        return nil if initiative_type.only_global_scope_enabled?

        super.presence
      end

      def initiative_type
        @initiative_type ||= InitiativesType.find(type_id)
      end

      def available_scopes
        @available_scopes ||= if initiative_type.only_global_scope_enabled?
                                initiative_type.scopes.where(scope: nil)
                              else
                                initiative_type.scopes
                              end
      end

      def scope
        @scope ||= Scope.find(scope_id) if scope_id.present?
      end

      private

      def scope_exists
        return if scope_id.blank?

        errors.add(:scope_id, :invalid) unless InitiativesTypeScope.where(type: initiative_type, scope: scope).exists?
      end
    end
  end
end
