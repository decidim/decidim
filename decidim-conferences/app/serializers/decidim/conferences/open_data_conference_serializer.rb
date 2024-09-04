# frozen_string_literal: true

module Decidim
  module Conferences
    # This class serializes a Conference so it can be exported to CSV for the Open Data feature.
    class OpenDataConferenceSerializer < Decidim::Exporters::Serializer
      include Decidim::ApplicationHelper
      include Decidim::ResourceHelper
      include Decidim::TranslationsHelper

      # Public: Initializes the serializer with a Conference instance.
      def initialize(conference)
        @conference = conference
      end

      # Public: Exports a hash with the serialized data for this conference.
      def serialize
        {
          id: conference.id,
          slug: conference.slug,
          hashtag: conference.hashtag,
          decidim_organization_id: conference.decidim_organization_id,
          title: conference.title,
          slogan: conference.slogan,
          reference: conference.reference,
          weight: conference.weight,
          short_description: conference.short_description,
          description: conference.description,
          remote_hero_image_url: Decidim::Conferences::ConferencePresenter.new(conference).hero_image_url,
          remote_banner_image_url: Decidim::Conferences::ConferencePresenter.new(conference).banner_image_url,
          location: conference.location,
          promoted: conference.promoted,
          objectives: conference.objectives,
          start_date: conference.start_date,
          end_date: conference.end_date,
          scopes_enabled: conference.scopes_enabled,
          decidim_scope_id: conference.decidim_scope_id,

          conference_categories: serialize_categories,
          scope: {
            id: conference.scope.try(:id),
            name: conference.scope.try(:name) || empty_translatable
          }
        }
      end

      private

      attr_reader :conference
      alias resource conference

      def serialize_categories
        return unless conference.categories.first_class.any?

        conference.categories.first_class.map do |category|
          {
            id: category.try(:id),
            name: category.try(:name),
            description: category.try(:description),
            parent_id: category.try(:parent_id),
            subcategories: serialize_subcategories(category.subcategories)
          }
        end
      end

      def serialize_subcategories(subcategories)
        return unless subcategories.any?

        subcategories.map do |subcategory|
          {
            id: subcategory.try(:id),
            name: subcategory.try(:name),
            description: subcategory.try(:description),
            parent_id: subcategory.try(:parent_id)
          }
        end
      end
    end
  end
end
