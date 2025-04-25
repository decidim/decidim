# frozen_string_literal: true

require "decidim/components/namer"
require "decidim/seeds"

module Decidim
  module Initiatives
    class Seeds < Decidim::Seeds
      def call
        create_content_block!

        number_of_records.times do |_n|
          type = create_initiative_type!

          organization.top_scopes.each do |scope|
            create_initiative_type_scope!(scope:, type:)
          end
        end

        Decidim::Initiative.states.keys.each do |state|
          Decidim::Initiative.skip_callback(:save, :after, :notify_state_change, raise: false)
          Decidim::Initiative.skip_callback(:create, :after, :notify_creation, raise: false)

          initiative = create_initiative!(state:)

          create_initiative_votes!(initiative:) if %w(published rejected accepted).include? state

          Decidim::Comments::Seed.comments_for(initiative)

          create_attachment(attached_to: initiative, filename: "city.jpeg")

          Decidim::Initiatives.default_components.each do |component_name|
            create_component!(initiative:, component_name:)
          end
        end
      end

      def create_content_block!
        Decidim::ContentBlock.create(
          organization:,
          weight: 33,
          scope_name: :homepage,
          manifest_name: :highlighted_initiatives,
          published_at: Time.current
        )
      end

      def create_initiative_type!
        Decidim::InitiativesType.create!(
          title: Decidim::Faker::Localized.sentence(word_count: 5),
          description: Decidim::Faker::Localized.sentence(word_count: 25),
          organization:,
          banner_image: ::Faker::Boolean.boolean(true_ratio: 0.5) ? banner_image : nil # Keep after organization
        )
      end

      def create_initiative_type_scope!(scope:, type:)
        n = rand(3)
        Decidim::InitiativesTypeScope.create(
          type:,
          scope:,
          supports_required: (n + 1) * 1000
        )
      end

      def create_initiative!(state:)
        published_at = %w(published rejected accepted).include?(state) ? 7.days.ago : nil

        params = {
          title: Decidim::Faker::Localized.sentence(word_count: 3),
          description: Decidim::Faker::Localized.sentence(word_count: 25),
          scoped_type: Decidim::InitiativesTypeScope.all.sample,
          state:,
          signature_type: "online",
          signature_start_date: Date.current - 7.days,
          signature_end_date: Date.current + 7.days,
          published_at:,
          author: Decidim::User.all.sample,
          organization:
        }

        initiative = Decidim.traceability.perform_action!(
          "publish",
          Decidim::Initiative,
          organization.users.first,
          visibility: "all"
        ) do
          Decidim::Initiative.create!(params)
        end
        initiative.add_to_index_as_search_resource

        initiative
      end

      def create_initiative_votes!(initiative:)
        users = []
        rand(50).times do
          author = (Decidim::User.all - users).sample
          initiative.votes.create!(author:, scope: initiative.scope, hash_id: SecureRandom.hex)
          users << author
        end
      end

      def create_component!(initiative:, component_name:)
        component = Decidim::Component.create!(
          name: Decidim::Components::Namer.new(initiative.organization.available_locales, component_name).i18n_name,
          manifest_name: component_name,
          published_at: Time.current,
          participatory_space: initiative
        )

        return unless component_name.in? ["pages", :pages]

        Decidim::Pages::CreatePage.call(component) do
          on(:invalid) { raise "Cannot create page" }
        end
      end
    end
  end
end
