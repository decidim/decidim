# frozen_string_literal: true

module Decidim
  module Core
    class BadgeScoreType < Decidim::Api::Types::BaseObject
      description "An user badge score"

      field :description, GraphQL::Types::String, "The description of this badge", null: false
      field :image, GraphQL::Types::String, "The image of this badge", null: false
      field :level, GraphQL::Types::Int, "The level of this badge", null: false
      field :name, GraphQL::Types::String, "The name of this badge", null: false, method: :badge_name
      field :score, GraphQL::Types::Int, "The score of this badge", null: false

      delegate :level, :score, to: :status
      delegate :image, :description, to: :manifest

      private

      def manifest
        @manifest ||= status.badge
      end

      def status
        @status ||= Decidim::Gamification.status_for(object.user, object.badge_name)
      end
    end
  end
end
