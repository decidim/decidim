module Decidim
  class Coauthorship < ApplicationRecord
    include Decidim::Authorable
    # belongs_to :author, foreign_key: "decidim_author_id", class_name: "Decidim::User"
    # belongs_to :user_group, foreign_key: "decidim_user_group_id", class_name: "Decidim::UserGroup", optional: true
    belongs_to :coauthorable, polymorphic: true

    validates :coauthorable, presence: true

    private

    # As it is used to validate by comparing to author.organization
    # @returns The Organization for the Coauthorable
    def organization
      coauthorable&.organization
    end
  end
end
