# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # This concern contains the logic related to data portability.
  module DataPortability
    extend ActiveSupport::Concern

    included do
      # validates :nickname, length: { maximum: nickname_max_length }, allow_blank: true

    end

    class_methods do
      def self.collection
        raise
      end
      # collection = Decidim::Proposals::Proposal.where(decidim_author_id: user.id)
      # serializer = Decidim::Proposals::ProposalSerializer
    end
  end
end
