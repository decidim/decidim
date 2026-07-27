# frozen_string_literal: true

module Decidim
  class StatsParticipantsCount < Decidim::Query
    def initialize(participatory_space)
      @participatory_space = participatory_space
    end

    def query
      [
        comments_query,
        debates_query,
        meetings_query,
        likes_query,
        project_votes_query,
        proposals_query,
        proposal_votes_query,
        survey_response_query
      ].flatten.uniq.count + meetings_attendees_count_query
    end

    private

    attr_reader :participatory_space

    def comments_query
      return [] unless Decidim.module_installed?(:comments)

      Decidim::Comments::Comment
        .where(participatory_space:)
        .pluck(:decidim_author_id)
        .uniq
    end

    def debates_query
      return [] unless Decidim.module_installed?(:debates)

      Decidim::Debates::Debate
        .where(component: space_components, decidim_author_type: Decidim::UserBaseEntity.name)
        .not_hidden
        .pluck(:decidim_author_id)
        .uniq
    end

    def meetings_query
      return [] unless Decidim.module_installed?(:meetings)

      meetings = Decidim::Meetings::Meeting.where(component: space_components).not_hidden

      meetings.where(decidim_author_type: Decidim::UserBaseEntity.name).pluck(:decidim_author_id)
    end

    def meetings_attendees_count_query
      return 0 unless Decidim.module_installed?(:meetings)

      Decidim::Meetings::Meeting
        .not_hidden
        .published
        .where(component: space_components, closing_visible: true)
        .sum(:attendees_count)
    end

    def likes_query
      component_ids = space_components.pluck(:id)
      return [] if component_ids.empty?

      queries = [Decidim::Like.where(resource_type: "Decidim::Component", resource_id: component_ids)]

      likeable_resource_types.each do |type|
        resource_ids = type.where(component: space_components).pluck(:id)
        next if resource_ids.empty?

        queries << Decidim::Like.where(resource_type: type.name, resource_id: resource_ids)
      end

      queries.flat_map { |q| q.pluck(:decidim_author_id) }.uniq
    end

    def likeable_resource_types
      @likeable_resource_types ||= ActiveRecord::Base.descendants.select do |klass|
        next false if klass.abstract_class? || klass.name.nil?

        reflection = klass.reflect_on_association(:likes)
        reflection&.macro == :has_many && reflection.options[:as] == :resource
      end
    end

    def proposals_query
      return [] unless Decidim.module_installed?(:proposals)

      Decidim::Coauthorship
        .where(coauthorable: proposals_components, decidim_author_type: Decidim::UserBaseEntity.name)
        .pluck(:decidim_author_id)
        .uniq
    end

    def proposal_votes_query
      return [] unless Decidim.module_installed?(:proposals)

      Decidim::Proposals::ProposalVote
        .where(proposal: proposals_components)
        .final
        .pluck(:decidim_author_id)
        .uniq
    end

    def project_votes_query
      return [] unless Decidim.module_installed?(:budgets)

      Decidim::Budgets::Order.joins(budget: [:component])
                             .where(budget: { decidim_components: { id: space_components.pluck(:id) } })
                             .pluck(:decidim_user_id)
                             .uniq
    end

    def survey_response_query
      Decidim::Forms::Response.newsletter_participant_ids(space_components)
    end

    def space_components
      @space_components ||= Decidim::Component.where(participatory_space:).published
    end

    def proposals_components
      @proposals_components ||= Decidim::Proposals::FilteredProposals.for(space_components).published.not_hidden
    end
  end
end
