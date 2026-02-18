# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This type represents a step on a participatory process.
    class ParticipatoryProcessStepType < Decidim::Api::Types::BaseObject
      description "A participatory process step"

      implements Decidim::Core::TimestampsInterface

      field :active, GraphQL::Types::Boolean, "If this step is the active one", null: true
      field :description, Decidim::Core::TranslatedFieldType, "The description of this step", null: true
      field :end_date, Decidim::Core::DateTimeType, "This step's end date", null: true
      field :id, GraphQL::Types::ID, "The unique ID of this step.", null: false
      field :participatory_process, ParticipatoryProcessType, description: "The participatory process in which this step belongs to.", null: false
      field :position, GraphQL::Types::Int, "Ordering position among all the steps", null: true
      field :start_date, Decidim::Core::DateTimeType, "This step's start date", null: true
      field :title, Decidim::Core::TranslatedFieldType, "The title of this step", null: false
    end
  end
end
