# frozen_string_literal: true

module Decidim
  module Initiatives
    # A command with all the business logic that creates a new initiative.
    class CreateInitiative < Decidim::Command
      include CurrentLocale
      include ::Decidim::MultipleAttachmentsMethods

      # Public: Initializes the command.
      #
      # form - A form object with the params.
      # current_user - Current user.
      def initialize(form, current_user)
        @form = form
        @current_user = current_user
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
          build_attachments
          return broadcast(:invalid) if attachments_invalid?
        end

        initiative = create_initiative

        if initiative.persisted?
          broadcast(:ok, initiative)
        else
          broadcast(:invalid, initiative)
        end
      end

      private

      attr_reader :form, :current_user, :attachment

      # Creates the initiative and all default components
      def create_initiative
        initiative = build_initiative
        return initiative unless initiative.valid?

        initiative.transaction do
          initiative.save!
          @attached_to = initiative
          create_attachments if process_attachments?

          create_components_for(initiative)
          send_notification(initiative)
          add_author_as_follower(initiative)
          add_author_as_committee_member(initiative)
        end

        initiative
      end

      def build_initiative
        Initiative.new(
          organization: form.current_organization,
          title: { current_locale => form.title },
          description: { current_locale => form.description },
          author: current_user,
          decidim_user_group_id: form.decidim_user_group_id,
          scoped_type:,
          area:,
          signature_type: form.signature_type,
          signature_end_date:,
          state: "created"
        )
      end

      def scoped_type
        InitiativesTypeScope.find_by(
          type: form.initiative_type,
          scope: form.scope
        )
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

          initialize_pages(component) if component_name == :pages
        end
      end

      def initialize_pages(component)
        Decidim::Pages::CreatePage.call(component) do
          on(:invalid) { raise "Can't create page" }
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

        Decidim::CreateFollow.new(form, current_user).call
      end

      def add_author_as_committee_member(initiative)
        form = Decidim::Initiatives::CommitteeMemberForm
               .from_params(initiative_id: initiative.id, user_id: initiative.decidim_author_id, state: "accepted")
               .with_context(
                 current_organization: initiative.organization,
                 current_user:
               )

        Decidim::Initiatives::SpawnCommitteeRequest.new(form, current_user).call
      end
    end
  end
end
