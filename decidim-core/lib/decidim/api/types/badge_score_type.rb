# frozen_string_literal: true

module Decidim
  module Core
    class BadgeScoreType < Decidim::Api::Types::BaseObject
      description "An user badge score"

      field :name, GraphQL::Types::String, "The badge's name", null: false, method: :badge_name
      field :score, GraphQL::Types::Int, "The badge's score", null: false
      field :level, GraphQL::Types::Int, "The badge's level", null: false
      field :description, GraphQL::Types::String, "The badge's description", null: false
      field :image, GraphQL::Types::String, "The badge's image", null: false

      delegate :level, :score, to: :status
      delegate :image, :description, to: :manifest

      private
      def manifest
        @manifest ||= status.badge
      end

      def status
        @status ||= Decidim::Gamification.status_for(Decidim::User.find(object.user_id), object.badge_name)
      end

    end
  end
end
