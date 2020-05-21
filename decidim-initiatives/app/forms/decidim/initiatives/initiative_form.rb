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
      attribute :signature_end_date, Date
      attribute :state, String

      validates :title, :description, presence: true
      validates :title, length: { maximum: 150 }
      validates :signature_type, presence: true
      validates :type_id, presence: true
      validate :scope_exists
      validates :signature_end_date, date: { after: Date.current }, if: lambda { |form|
        form.context.initiative_type.custom_signature_end_date_enabled? && form.signature_end_date.present?
      }

      def map_model(model)
        self.type_id = model.type.id
        self.scope_id = model.scope&.id
      end

      def signature_type_updatable?
        state == "created" || state.nil?
      end

      def scope_id
        super.presence
      end

      private

      def scope_exists
        return if scope_id.blank?

        errors.add(:scope_id, :invalid) unless InitiativesTypeScope.where(decidim_initiatives_types_id: type_id, decidim_scopes_id: scope_id).exists?
      end
    end
  end
end
