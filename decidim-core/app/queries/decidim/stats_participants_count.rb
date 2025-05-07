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
        endorsements_query,
        project_votes_query,
        proposals_query,
        proposal_votes_query,
        survey_response_query
      ].flatten.uniq.count
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
      registrations = Decidim::Meetings::Registration.where(decidim_meeting_id: meetings).pluck(:decidim_user_id)
      organizers = meetings.where(decidim_author_type: Decidim::UserBaseEntity.name).pluck(:decidim_author_id)

      [registrations, organizers].flatten.uniq
    end

    def endorsements_query
      Decidim::Endorsement
        .where(resource: space_components)
        .pluck(:decidim_author_id)
        .uniq
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
