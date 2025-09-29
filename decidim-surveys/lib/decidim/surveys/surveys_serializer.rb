module Decidim
  module Surveys
    # This class serializes a Survey so can be exported to CSV, JSON or other
    # formats.
    class SurveysSerializer < Decidim::Exporters::Serializer
      include Decidim::ApplicationHelper
      include Decidim::ResourceHelper

      # Public: Exports a hash with the serialized data for this survey.
      def serialize
        {
          id: resource.id,
          title: resource.title,
          description: resource.description,
          created_at: resource.created_at,
          updated_at: resource.updated_at,
          participatory_space: {
            id: resource.participatory_space.id,
            url: Decidim::ResourceLocatorPresenter.new(resource.participatory_space).url
          },
          component: { id: component.id },
          url:
        }
      end

      private

      def url
        Decidim::ResourceLocatorPresenter.new(resource).url
      end
    end
  end
end
