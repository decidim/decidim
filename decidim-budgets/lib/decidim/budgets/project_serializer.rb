# frozen_string_literal: true

module Decidim
  module Budgets
    class ProjectSerializer < Decidim::Exporters::Serializer
      include Decidim::ApplicationHelper
      include Decidim::ResourceHelper
      include Decidim::TranslationsHelper

      # Public: Initializes the serializer with a project.
      def initialize(project)
        @project = project
      end

      # Public: Exports a hash with the serialized data for this project.
      def serialize
        {
          id: project.id,
          author: {
            **author_fields
          },
          taxonomies: {
            id: project.taxonomies.map(&:id),
            name: project.taxonomies.map(&:name)
          },
          participatory_space: {
            id: project.participatory_space.id,
            url: Decidim::ResourceLocatorPresenter.new(project.participatory_space).url
          },
          component: { id: component.id },
          title: project.title,
          description: project.description,
          budget: { id: project.budget.id },
          budget_amount: project.budget_amount,
          confirmed_votes: project.confirmed_orders_count,
          comments: project.comments_count,
          created_at: project.created_at,
          url: project.polymorphic_resource_url({}),
          address: project.address,
          updated_at: project.updated_at,
          reference: project.reference,
          related_proposals:,
          related_proposal_titles:,
          related_proposal_urls:
        }
      end

      private

      attr_reader :project
      alias resource project

      def component
        project.component
      end

      def related_proposals
        project.linked_resources(:proposals, "included_proposals").map(&:id)
      end

      def related_proposal_titles
        project.linked_resources(:proposals, "included_proposals").map do |proposal|
          Decidim::Proposals::ProposalPresenter.new(proposal).title
        end
      end

      def related_proposal_urls
        project.linked_resources(:proposals, "included_proposals").map do |proposal|
          Decidim::ResourceLocatorPresenter.new(proposal).url
        end
      end

      def url
        Decidim::ResourceLocatorPresenter.new(project).url
      end

      def author_fields
        {
          id: resource.author.id,
          name: author_name(resource.author),
          url: author_url(resource.author)
        }
      end

      def author_name(author)
        translated_attribute(author.name)
      end

      def author_url(author)
        if author.respond_to?(:nickname)
          profile_url(author) # is a Decidim::User or Decidim::UserGroup
        else
          root_url # is a Decidim::Organization
        end
      end

      def profile_url(author)
        return "" if author.respond_to?(:deleted?) && author.deleted?

        Decidim::Core::Engine.routes.url_helpers.profile_url(author.nickname, host:)
      end

      def root_url
        Decidim::Core::Engine.routes.url_helpers.root_url(host:)
      end

      def host
        resource.organization.host
      end

      def empty_translatable(locales = Decidim.available_locales)
        locales.each_with_object({}) do |locale, result|
          result[locale.to_s] = ""
        end
      end
    end
  end
end
