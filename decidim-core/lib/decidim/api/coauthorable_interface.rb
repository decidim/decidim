# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents a coauthorable object.

    module CoauthorableInterface
      include GraphQL::Schema::Interface
      # name "CoauthorableInterface"
      description "An interface that can be used in coauthorable objects."

      field :authorsCount, Int, null: true, description: "The total amount of co-authors that contributed to the proposal. Note that this field may include also non-user authors like meetings or the organization"
      field :authors, [Decidim::Core::AuthorInterface], null: false, description: "The resource co-authors. Include only users or groups of users"
      field :author, Decidim::Core::AuthorInterface, null: true, description: "The resource author. Note that this can be null on official proposals or meeting-proposals" do
        def resolve(resource:, atguments:, context:)
          author = resource.creator_identity
          author if author.is_a?(Decidim::User) || author.is_a?(Decidim::UserGroup)
        end
      end

      def authorsCount
        object.coauthorships_count
      end

      def authors
        object.user_identities
      end
    end
  end
end
