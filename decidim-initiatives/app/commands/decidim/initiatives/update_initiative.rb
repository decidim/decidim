# frozen_string_literal: true

module Decidim
  module Initiatives
    # A command with all the business logic that updates an
    # existing initiative.
    class UpdateInitiative < Rectify::Command
      include Decidim::Initiatives::AttachmentMethods

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

          build_attachment
          return broadcast(:invalid) if attachment_invalid?
        end

        @initiative = Decidim.traceability.update!(
          initiative,
          current_user,
          attributes
        )
        create_attachment if process_attachments?
        notify_initiative_is_extended if @notify_extended
        broadcast(:ok, initiative)
      rescue ActiveRecord::RecordInvalid
        broadcast(:invalid, initiative)
      end

      private

      attr_reader :form, :initiative, :current_user, :attachment

      def attributes
        attrs = {
          title: form.title,
          description: form.description,
          hashtag: form.hashtag
        }

        if form.signature_type_updatable?
          attrs[:signature_type] = form.signature_type
          attrs[:scoped_type_id] = form.scoped_type_id if form.scoped_type_id
        end

        if current_user.admin?
          add_admin_accessible_attrs(attrs)
        elsif initiative.created?
          attrs[:signature_end_date] = form.signature_end_date if initiative.custom_signature_end_date_enabled?
          attrs[:decidim_area_id] = form.area_id if initiative.area_enabled?
        end

        attrs
      end

      def add_admin_accessible_attrs(attrs)
        attrs[:signature_start_date] = form.signature_start_date
        attrs[:signature_end_date] = form.signature_end_date
        attrs[:offline_votes] = form.offline_votes if form.offline_votes
        attrs[:state] = form.state if form.state
        attrs[:decidim_area_id] = form.area_id

        @notify_extended = form.signature_end_date != initiative.signature_end_date && form.signature_end_date > initiative.signature_end_date if initiative.published?
      end

      def notify_initiative_is_extended
        Decidim::EventsManager.publish(
          event: "decidim.events.initiatives.initiative_extended",
          event_class: Decidim::Initiatives::ExtendInitiativeEvent,
          resource: initiative,
          followers: initiative.followers - [initiative.author]
        )
      end
    end
  end
end
