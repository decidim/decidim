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

    belongs_to :scope,
               foreign_key: "decidim_scope_id",
               class_name: "Decidim::Scope",
               optional: true

    validates :initiative, uniqueness: { scope: [:author, :user_group, :scope] }
    validates :initiative, uniqueness: { scope: [:hash_id, :scope] }

    after_commit :update_counter_cache, on: [:create, :destroy]

    scope :from_user_groups, -> { where.not(decidim_user_group_id: nil) }
    scope :from_users, -> { where(decidim_user_group_id: nil) }
    scope :for_scope, ->(scope) { where(scope: scope) }

    # Public: Generates a hashed representation of the initiative support.
    #
    # Used when exporting the votes as CSV.
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
      initiative.update_online_votes_counters
    end
  end
end
