# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This type represents a phase on a participatory process.
    class ParticipatoryProcessPhaseType < Decidim::Api::Types::BaseObject
      description "A participatory process phase"

      implements Decidim::Core::TimestampsInterface

      field :active, GraphQL::Types::Boolean, "If this phase is the active one", null: true
      field :description, Decidim::Core::TranslatedFieldType, "The description of this phase", null: true
      field :end_date, Decidim::Core::DateTimeType, "This phase's end date", null: true
      field :id, GraphQL::Types::ID, "The unique ID of this phase.", null: false
      field :participatory_process, ParticipatoryProcessType, description: "The participatory process in which this phase belongs to.", null: false
      field :position, GraphQL::Types::Int, "Ordering position among all the phases", null: true
      field :start_date, Decidim::Core::DateTimeType, "This phase's start date", null: true
      field :title, Decidim::Core::TranslatedFieldType, "The title of this phase", null: false
    end
  end
end
