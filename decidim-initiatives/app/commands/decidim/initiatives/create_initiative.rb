# frozen_string_literal: true

require "decidim/components/namer"

module Decidim
  module Initiatives
    # A command with all the business logic that creates a new initiative.
    class CreateInitiative < Decidim::Command
      include CurrentLocale
      include ::Decidim::MultipleAttachmentsMethods
      include ::Decidim::GalleryMethods

      delegate :current_user, to: :form
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(form)
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form was not valid and we could not proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        if process_attachments?
          build_attachments
          return broadcast(:invalid) if attachments_invalid?
        end

        if process_gallery?
          build_gallery
          return broadcast(:invalid) if gallery_invalid?
        end

        initiative = create_initiative

        if initiative.persisted?
          broadcast(:ok, initiative)
        else
          broadcast(:invalid, initiative)
        end
      end

      protected

      def event_arguments
        {
          resource: initiative,
          extra: {
            event_author: form.current_user,
            locale:
          }
        }
      end

      private

      attr_reader :form, :attachment, :initiative

      # Creates the initiative and all default components
      def create_initiative
        build_initiative
        return initiative unless initiative.valid?

        with_events(with_transaction: true) do
          initiative.save!

          @attached_to = initiative
          create_attachments if process_attachments?
          create_gallery if process_gallery?

          create_components_for(initiative)
          send_notification(initiative)
          add_author_as_follower(initiative)
          add_author_as_committee_member(initiative)
        end

        initiative
      end

      def build_initiative
        @initiative = Initiative.new(
          organization: form.current_organization,
          title: { current_locale => form.title },
          description: { current_locale => form.description },
          hashtag: form.hashtag,
          author: current_user,
          scoped_type:,
          signature_type: form.type.signature_type,
          decidim_area_id: form.area_id,
          state: "created"
        )
      end

      def scoped_type
        InitiativesTypeScope.order(:id).find_by(type: form.type, scope: form.scope)
      end

      def signature_end_date
        return nil unless form.context.initiative_type.custom_signature_end_date_enabled?

        form.signature_end_date
      end

      def area
        return nil unless form.context.initiative_type.area_enabled?

        form.area
      end

      def create_components_for(initiative)
        Decidim::Initiatives.default_components.each do |component_name|
          component = Decidim::Component.create!(
            name: Decidim::Components::Namer.new(initiative.organization.available_locales, component_name).i18n_name,
            manifest_name: component_name,
            published_at: Time.current,
            participatory_space: initiative
          )

          initialize_pages(component) if component_name.in? ["pages", :pages]
        end
      end

      def initialize_pages(component)
        Decidim::Pages::CreatePage.call(component) do
          on(:invalid) { raise "Cannot create page" }
        end
      end

      def send_notification(initiative)
        Decidim::EventsManager.publish(
          event: "decidim.events.initiatives.initiative_created",
          event_class: Decidim::Initiatives::CreateInitiativeEvent,
          resource: initiative,
          followers: initiative.author.followers
        )
      end

      def add_author_as_follower(initiative)
        form = Decidim::FollowForm
               .from_params(followable_gid: initiative.to_signed_global_id.to_s)
               .with_context(
                 current_organization: initiative.organization,
                 current_user:
               )

        Decidim::CreateFollow.new(form).call
      end

      def add_author_as_committee_member(initiative)
        form = Decidim::Initiatives::CommitteeMemberForm
               .from_params(initiative_id: initiative.id, user_id: initiative.decidim_author_id, state: "accepted")
               .with_context(
                 current_organization: initiative.organization,
                 current_user:
               )

        Decidim::Initiatives::SpawnCommitteeRequest.new(form).call
      end
    end
  end
end
