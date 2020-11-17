# frozen_string_literal: true

module Decidim
  module Api
    # Main GraphQL schema for decidim's API.
    class Schema < GraphQL::Schema
      query QueryType
      mutation MutationType

      default_max_page_size 50
      max_depth 15
      max_complexity 300

      # orphan_types(Api.orphan_types)

      orphan_types([
                     # Decidim::Pages::PagesType,
                     # Decidim::Meetings::MeetingsType,
                     # Decidim::Proposals::ProposalsType,
                     # Decidim::Budgets::BudgetsType,
                     # Decidim::Surveys::SurveysType,
                     # Decidim::Accountability::AccountabilityType,
                     # Decidim::Debates::DebatesType,
                     # Decidim::Sortitions::SortitionsType,
                     # Decidim::Blogs::BlogsType,
                     # Decidim::ParticipatoryProcesses::ParticipatoryProcessType,
                     # Decidim::Assemblies::AssemblyType,
                     # Decidim::Conferences::ConferenceType,
                     # Decidim::Core::UserType,
                     Decidim::Core::UserGroupType
                   ])

      def resolve_type(_type, _obj, _ctx)
        Decidim::Api::Schema
      end
    end
  end
end
