# frozen_string_literal: true

module Decidim
  module Debates
    class DebatesMutationType < Decidim::Core::ComponentType
      description "A debates component."

      field :create_debate, mutation: Decidim::Debates::CreateDebateType, description: "Creates a debate"
      field :debate, type: Decidim::Debates::DebateMutationType, description: "Mutates a debate", null: true do
        argument :id, GraphQL::Types::ID, "The ID of the debate", required: false
      end

      def debate(id: nil)
        collection.find(id)
      end

      private

      def collection
        Debate.where(component: object).not_hidden
      end
    end
  end
end
