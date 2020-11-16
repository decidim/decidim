# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This type represents a step on a participatory process.
    class ParticipatoryProcessStepType < GraphQL::Schema::Object
    graphql_name  "ParticipatoryProcessStep"
      description "A participatory process step"

      field :id, ID, null: false, description: "The unique ID of this step."
      field :participatoryProcess, ParticipatoryProcessType,  null: false, description: "The participatory process in which this step belongs to."
      field :title, Decidim::Core::TranslatedFieldType,  null: false, description: "The title of this step"
      field :description, Decidim::Core::TranslatedFieldType, null: true, description:  "The description of this step"
      field :startDate, Decidim::Core::DateType, null: true, description: "This step's start date"
      field :endDate, Decidim::Core::DateType, null: true, description: "This step's end date"
      field :callToActionPath, String, null: true, description:"A call to action URL for this step"
      field :callToActionText, Decidim::Core::TranslatedFieldType, null: true, description: "The call to action text for this step"
      field :active, Boolean, null: true, description: "If this step is the active one"
      field :position, Int, null: true, description: "Ordering position among all the steps"

    def startDate
      start_date
    end

    def endDate
      end_date
    end

    def callToActionPath
      cta_path
    end

    def callToActionText
      cta_text
    end
      def participatoryProcess
        object.participatory_process
      end
    end
  end
end
