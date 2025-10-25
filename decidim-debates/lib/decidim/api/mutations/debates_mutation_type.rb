# frozen_string_literal: true

module Decidim
  module Debates
    class DebatesMutationType < Decidim::Core::ComponentType
      description "A debates component."

      field :debate, type: Decidim::Debates::DebateMutationType, description: "Mutates a debate", null: true do
        argument :id, GraphQL::Types::ID, "The ID of the debate", required: false
      end

      field :create_debate, mutation: Decidim::Debates::CreateDebateType, description: "Creates a debate"

      def debate(id: nil)
        id ? collection.find(id) : nil
      end

      private

      def collection
        Debate.where(component: object).not_hidden
      end
    end
  end
end
