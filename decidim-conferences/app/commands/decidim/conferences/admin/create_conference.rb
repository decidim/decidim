# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when creating a new participatory
      # conference in the system.
      class CreateConference < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          if conference.persisted?
            add_admins_as_followers(conference)
            link_participatory_processes(conference)

            broadcast(:ok, conference)
          else
            form.errors.add(:hero_image, conference.errors[:hero_image]) if conference.errors.include? :hero_image
            form.errors.add(:banner_image, conference.errors[:banner_image]) if conference.errors.include? :banner_image
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form

        def conference
          @conference ||= Decidim.traceability.create(
            Conference,
            form.current_user,
            organization: form.current_organization,
            title: form.title,
            slogan: form.subtitle,
            slug: form.slug,
            hashtag: form.hashtag,
            description: form.description,
            short_description: form.short_description,
            hero_image: form.hero_image,
            banner_image: form.banner_image,
            promoted: form.promoted,
            scopes_enabled: form.scopes_enabled,
            scope: form.scope,
            show_statistics: form.show_statistics,
          )
        end

        def add_admins_as_followers(conference)
          conference.organization.admins.each do |admin|
            form = Decidim::FollowForm
                   .from_params(followable_gid: conference.to_signed_global_id.to_s)
                   .with_context(
                     current_organization: conference.organization,
                     current_user: admin
                   )

            Decidim::CreateFollow.new(form, admin).call
          end
        end

      end
    end
  end
end
