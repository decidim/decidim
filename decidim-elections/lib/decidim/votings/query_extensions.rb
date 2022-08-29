# frozen_string_literal: true

module Decidim
  module Votings
    # This module's job is to extend the API with custom fields related to
    # decidim-votings.
    module QueryExtensions
      # Public: Extends a type with `decidim-votings`'s fields.
      #
      # type - A GraphQL::BaseType to extend.
      #
      # Returns nothing.
      def self.included(type)
        type.field :votings,
                   [Decidim::Votings::VotingType],
                   null: true,
                   description: "Lists all votings" do
          argument :filter, Decidim::ParticipatoryProcesses::ParticipatoryProcessInputFilter, "This argument let's you filter the results", required: false
          argument :order, Decidim::ParticipatoryProcesses::ParticipatoryProcessInputSort, "This argument let's you order the results", required: false
        end

        type.field :voting,
                   Decidim::Votings::VotingType,
                   null: true,
                   description: "Finds a voting" do
          argument :id, GraphQL::Types::ID, "The ID of the participatory space", required: false
        end
      end

      def votings(filter: {}, order: {})
        manifest = Decidim.participatory_space_manifests.select { |m| m.name == :votings }.first

        Decidim::Core::ParticipatorySpaceListBase.new(manifest:).call(object, { filter:, order: }, context)
      end

      def voting(id: nil)
        manifest = Decidim.participatory_space_manifests.select { |m| m.name == :votings }.first

        Decidim::Core::ParticipatorySpaceFinderBase.new(manifest:).call(object, { id: }, context)
      end
    end
  end
end
