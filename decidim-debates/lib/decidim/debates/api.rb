# frozen_string_literal: true

module Decidim
  module Debates
    autoload :DebateType, "decidim/api/debate_type"
    autoload :DebatesType, "decidim/api/debates_type"
    autoload :DebatesMutationType, "decidim/api/mutations/debates_mutation_type"
    autoload :DebateMutationType, "decidim/api/mutations/debate_mutation_type"
    autoload :UpdateDebateType, "decidim/api/mutations/update_debate_type"
    autoload :UpdateDebateAttributes, "decidim/api/mutations/update_debate_attributes"
  end
end
