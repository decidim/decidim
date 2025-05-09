# frozen_string_literal: true

require "cell/partial"

module Decidim
  # This cell renders the list of likes.
  #
  # Example:
  #
  #    cell("decidim/likes_list", my_component)
  class EndorsersListCell < Decidim::ViewModel
    include ApplicationHelper

    MAX_ITEMS_STACKED = 8

    def show
      return render :empty if visible_endorsers.count.zero?
      return render :full if full_list?

      render
    end

    def endorsers_count
      base_relation.count
    end

    private

    def full_list?
      options[:layout] == :full
    end

    # Finds the correct author for each like.
    #
    # Returns an Array of presented Users
    def visible_endorsers
      @visible_endorsers ||= if voted_by_me?
                               base_relation.where.not(author: current_user).limit(MAX_ITEMS_STACKED - 1).map do |identity|
                                 present(identity.author)
                               end + [present(current_user)]
                             else
                               base_relation.limit(MAX_ITEMS_STACKED).map { |identity| present(identity.author) }
                             end
    end

    def full_endorsers
      @full_endorsers ||= base_relation.map { |identity| present(identity.author) }
    end

    def base_relation
      @base_relation ||= model.likes.for_listing.includes(:author)
    end

    def voted_by_me?
      @voted_by_me ||= model.endorsed_by?(current_user)
    end

    def display_link(text, css_class: "")
      link_to(text, "#",
              class: "text-sm font-semibold text-secondary inline-block #{css_class}",
              data: { "dialog-open": "endorsersModal-#{model.id}" })
    end
  end
end
