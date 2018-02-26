# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This type represents a step on a participatory process.
    ParticipatoryProcessStepType = GraphQL::ObjectType.define do
      name "ParticipatoryProcessStep"
      description "A participatory process step"

      field :id, !types.ID, "The unique ID of this step."

      field :participatoryProcess do
        type !ParticipatoryProcessType
        description "The participatory process in which this step belongs to."
        property :participatory_process
      end

      field :title, !Decidim::Core::TranslatedFieldType, "The title of this step"

      field :startDate, Decidim::Core::DateType, "This step's start date.", property: :start_date

      field :endDate, Decidim::Core::DateType, "This step's end date.", property: :end_date
    end
  end
end
