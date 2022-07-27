# frozen_string_literal: true

module Decidim
  module Elections
    # The data store for a trustee in the Decidim::Elections component. It stores a
    # public key and has a reference to Decidim::User.
    class Trustee < ApplicationRecord
      belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"
      belongs_to :organization, foreign_key: "decidim_organization_id", class_name: "Decidim::Organization"
      has_many :elections_trustees, foreign_key: "decidim_elections_trustee_id", dependent: :destroy
      has_many :elections, through: :elections_trustees
      has_many :trustees_participatory_spaces, inverse_of: :trustee, foreign_key: "decidim_elections_trustee_id", dependent: :destroy

      def self.trustee?(user)
        exists?(user:)
      end

      def self.log_presenter_class_for(_log)
        Decidim::Elections::AdminLog::TrusteePresenter
      end

      def self.for(user)
        find_by(user:)
      end

      def slug
        name.parameterize
      end

      # The bulletin_board_slug is used as `unique_id` on the Bulletin Board, where
      # the "authority.name" gets added as identification. If the organization
      # name would be missing, it could result in an error, when two organizations
      # inside the same "authority" have a trustee with the same name.
      def bulletin_board_slug
        "#{organization.name.parameterize}-#{slug}"
      end
    end
  end
end
