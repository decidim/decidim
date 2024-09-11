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

    MAX_ITEMS_STACKED = 8

    def show
      return if visible_endorsers.count.zero?

      return render :full if full_list?

      render
    end

    def full_endorsers_list
      render
    end

    def endorsers_count
      base_relation.count
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

    def voted_by_me?
      model.endorsed_by?(current_user)
    end

    def display_link(text)
      link_to(text, "#",
              class: "text-sm font-semibold text-secondary inline-block first-letter:uppercase",
              data: { "dialog-open": "endorsersModal-#{model.id}" })
    end
  end
end
