# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # A command with all the business logic that updates an
      # existing initiative.
      class UpdateInitiative < Decidim::Commands::UpdateResource
        include Decidim::Initiatives::AttachmentMethods

        protected

        attr_reader :attachment

        def update_resource
          super
        rescue ActiveRecord::RecordInvalid
          raise Decidim::Commands::HookError
        end

        def run_after_hooks
          create_attachment if process_attachments?
          notify_initiative_is_extended if @notify_extended
        end

        def run_before_hooks
          return unless process_attachments?

          resource.attachments.destroy_all

          @attached_to = resource

          build_attachment
          raise Decidim::Commands::HookError if attachment_invalid?
        end

        def attributes
          attrs = {
            title: form.title,
            description: form.description
          }

          if form.signature_type_updatable?
            attrs[:signature_type] = form.signature_type
            attrs[:scoped_type_id] = form.scoped_type_id if form.scoped_type_id
          end

          if current_user.admin?
            add_admin_accessible_attrs(attrs)
          elsif resource.created?
            attrs[:signature_end_date] = form.signature_end_date if resource.custom_signature_end_date_enabled?
            attrs[:decidim_area_id] = form.area_id if resource.area_enabled?
          end

          attrs
        end

        def add_admin_accessible_attrs(attrs)
          attrs[:signature_start_date] = form.signature_start_date
          attrs[:signature_end_date] = form.signature_end_date
          attrs[:offline_votes] = form.offline_votes if form.offline_votes
          attrs[:state] = form.state if form.state
          attrs[:decidim_area_id] = form.area_id

          if resource.published? && form.signature_end_date != resource.signature_end_date &&
             form.signature_end_date > resource.signature_end_date
            @notify_extended = true
          end
        end

        def notify_initiative_is_extended
          Decidim::EventsManager.publish(
            event: "decidim.events.initiatives.initiative_extended",
            event_class: Decidim::Initiatives::ExtendInitiativeEvent,
            resource:,
            followers: resource.followers - [resource.author]
          )
        end
      end
    end
  end
end
