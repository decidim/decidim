# frozen_string_literal: true

module Decidim
  module Initiatives
    # A command with all the business logic that updates an
    # existing initiative.
    class UpdateInitiative < Rectify::Command
      include ::Decidim::MultipleAttachmentsMethods
      include CurrentLocale

      # Public: Initializes the command.
      #
      # initiative - Decidim::Initiative
      # form       - A form object with the params.
      def initialize(initiative, form, current_user)
        @form = form
        @initiative = initiative
        @current_user = current_user
        @attached_to = initiative
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        if process_attachments?
          @initiative.attachments.destroy_all

          build_attachments
          return broadcast(:invalid) if attachments_invalid?
        end
        @initiative = Decidim.traceability.update!(
          initiative,
          current_user,
          attributes
        )

        create_attachments if process_attachments?
        broadcast(:ok, initiative)
      rescue ActiveRecord::RecordInvalid
        broadcast(:invalid, initiative)
      end

      private

      attr_reader :form, :initiative, :current_user

      def attributes
        attrs = {
          title: { current_locale => form.title },
          description: { current_locale => form.description }
        }

        if form.signature_type_updatable?
          attrs[:signature_type] = form.signature_type
          attrs[:scoped_type_id] = form.scoped_type_id if form.scoped_type_id
        end

        if initiative.created?
          attrs[:signature_end_date] = form.signature_end_date if initiative.custom_signature_end_date_enabled?
          attrs[:decidim_area_id] = form.area_id if initiative.area_enabled?
        end

        attrs
      end
    end
  end
end
