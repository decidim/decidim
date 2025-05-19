# frozen_string_literal: true

require "cell/partial"

module Decidim
  # This cell renders the list of likes.
  #
  # Example:
  #
  #    cell("decidim/likers_list", my_component)
  class LikersListCell < Decidim::ViewModel
    include ApplicationHelper

    MAX_ITEMS_STACKED = 8

    def show
      return render :empty if visible_likes.count.zero?
      return render :full if full_list?

      render
    end

    def likes_count
      base_relation.count
    end

    private

    def full_list?
      options[:layout] == :full
    end

    # Finds the correct author for each like.
    #
    # Returns an Array of presented Users
    def visible_likes
      @visible_likes ||= if voted_by_me?
                           base_relation.where.not(author: current_user).limit(MAX_ITEMS_STACKED - 1).map do |identity|
                             present(identity.author)
                           end + [present(current_user)]
                         else
                           base_relation.limit(MAX_ITEMS_STACKED).map { |identity| present(identity.author) }
                         end
    end

    def full_likes
      @full_likes ||= base_relation.map { |identity| present(identity.author) }
    end

    def base_relation
      @base_relation ||= model.likes.for_listing.includes(:author)
    end

    def voted_by_me?
      @voted_by_me ||= model.liked_by?(current_user)
    end

    def display_link(text, css_class: "")
      link_to(text, "#",
              class: "text-sm font-semibold text-secondary inline-block #{css_class}",
              data: { "dialog-open": "likesModal-#{model.id}" })
    end
  end
end
