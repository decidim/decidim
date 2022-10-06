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
          category: {
            id: project.category.try(:id),
            name: project.category.try(:name) || empty_translatable
          },
          scope: {
            id: project.scope.try(:id),
            name: project.scope.try(:name) || empty_translatable
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

      def empty_translatable(locales = Decidim.available_locales)
        locales.each_with_object({}) do |locale, result|
          result[locale.to_s] = ""
        end
      end
    end
  end
end
