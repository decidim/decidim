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
      attribute :area_id, Integer
      attribute :decidim_user_group_id, Integer
      attribute :signature_type, String
      attribute :signature_end_date, Date
      attribute :state, String
      attribute :attachment, AttachmentForm
      attribute :documents, Array[String]
      attribute :add_documents, Array
      attribute :photos, Array[String]
      attribute :hashtag, String

      validates :title, :description, presence: true
      validates :title, length: { maximum: 150 }
      validates :signature_type, presence: true
      validates :type_id, presence: true
      validates :area, presence: true, if: ->(form) { form.area_id.present? }
      validate :scope_exists
      validate :notify_missing_attachment_if_errored
      validate :trigger_attachment_errors
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

      def state_updatable?
        false
      end

      def scope_id
        return nil if initiative_type.only_global_scope_enabled?

        super.presence
      end

      def area
        @area ||= current_organization.areas.find_by(id: area_id)
      end

      def initiative_type
        @initiative_type ||= type_id ? InitiativesType.find(type_id) : context.initiative.type
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

      def scoped_type_id
        return unless type && scope_id

        type.scopes.find_by(decidim_scopes_id: scope_id.presence).id
      end

      private

      def type
        @type ||= type_id ? Decidim::InitiativesType.find(type_id) : context.initiative.type
      end

      def scope_exists
        return if scope_id.blank?

        errors.add(:scope_id, :invalid) unless InitiativesTypeScope.exists?(type: initiative_type, scope: scope)
      end

      # This method will add an error to the `attachment` field only if there's
      # any error in any other field. This is needed because when the form has
      # an error, the attachment is lost, so we need a way to inform the user of
      # this problem.
      def notify_missing_attachment_if_errored
        return if attachment.blank?

        errors.add(:attachment, :needs_to_be_reattached) if errors.any?
      end

      def trigger_attachment_errors
        return if attachment.blank?
        return if attachment.valid?

        attachment.errors.each { |error| errors.add(:attachment, error) }

        attachment = Attachment.new(
          attached_to: attachment.try(:attached_to),
          file: attachment.try(:file)
        )

        errors.add(:attachment, :file) if !attachment.save && attachment.errors.has_key?(:file)
      end
    end
  end
end
