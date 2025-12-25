# frozen_string_literal: true

module Decidim
  module Debates
    autoload :DebateType, "decidim/api/debate_type"
    autoload :DebatesType, "decidim/api/debates_type"
    autoload :CreateDebateType, "decidim/api/mutations/create_debate_type"
    autoload :DebateAttributes, "decidim/api/mutations/debate_attributes"
    autoload :DebatesMutationType, "decidim/api/mutations/debates_mutation_type"
    autoload :DebateMutationType, "decidim/api/mutations/debate_mutation_type"
  end
end
