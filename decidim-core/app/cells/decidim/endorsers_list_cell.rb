# frozen_string_literal: true

require "cell/partial"

module Decidim
  # This cell renders the list of endorsers.
  #
  # Example:
  #
  #    cell("decidim/endorsers_list", my_component)
  class EndorsersListCell < Decidim::ViewModel
    include ApplicationHelper

    MAX_ITEMS_STACKED = 3

    def show
      return unless base_relation.exists?

      return render :full if full_list?

      render
    end

    private

    def full_list?
      options[:layout] == :full
    end

    # Finds the correct author for each endorsement.
    #
    # Returns an Array of presented Users/UserGroups
    def visible_endorsers
      @visible_endorsers ||= base_relation.limit(MAX_ITEMS_STACKED).map { |identity| present(identity.normalized_author) }
    end

    def full_endorsers
      @full_endorsers ||= base_relation.map { |identity| present(identity.normalized_author) }
    end

    def base_relation
      @base_relation ||= model.endorsements.for_listing.includes(:author, :user_group)
    end

    def endorsers_count
      base_relation.count
    end
  end
end
