# frozen_string_literal: true

require "digest/sha1"

module Decidim
  # Initiatives can be voted by users and supported by organizations.
  class InitiativesVote < ApplicationRecord
    include Decidim::TranslatableAttributes

    belongs_to :author,
               foreign_key: "decidim_author_id",
               class_name: "Decidim::User"

    belongs_to :user_group,
               foreign_key: "decidim_user_group_id",
               class_name: "Decidim::UserGroup",
               optional: true

    belongs_to :initiative,
               foreign_key: "decidim_initiative_id",
               class_name: "Decidim::Initiative",
               inverse_of: :votes

    validates :initiative, uniqueness: { scope: [:author, :user_group] }

    after_commit :update_counter_cache, on: [:create, :destroy]

    scope :supports, -> { where.not(decidim_user_group_id: nil) }
    scope :votes, -> { where(decidim_user_group_id: nil) }

    # PUBLIC
    #
    # Generates a hashed representation of the initiative support.
    def sha1
      return unless decidim_user_group_id.nil?

      title = translated_attribute(initiative.title)
      description = translated_attribute(initiative.description)

      Digest::SHA1.hexdigest "#{authorization_unique_id}#{title}#{description}"
    end

    private

    def authorization_unique_id
      first_authorization = Decidim::Initiatives::UserAuthorizations
                            .for(author)
                            .first

      first_authorization&.unique_id || author.email
    end

    def update_counter_cache
      initiative.initiative_votes_count = Decidim::InitiativesVote
                                          .votes
                                          .where(decidim_initiative_id: initiative.id)
                                          .count

      initiative.initiative_supports_count = Decidim::InitiativesVote
                                             .supports
                                             .where(decidim_initiative_id: initiative.id)
                                             .count

      initiative.save
    end
  end
end
