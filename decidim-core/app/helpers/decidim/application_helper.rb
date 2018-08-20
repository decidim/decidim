# frozen_string_literal: true

module Decidim
  # Main module to add application-wide helpers.
  module ApplicationHelper
    include Decidim::OmniauthHelper
    include Decidim::ScopesHelper

    # Truncates a given text respecting its HTML tags.
    #
    # text    - The String text to be truncated.
    # options - A Hash with the options to truncate the text (default: {}):
    #           :length - An Integer number with the max length of the text.
    #           :separator - A String to append to the text when it's being
    #           truncated. See `truncato` gem for more options.
    #
    # Returns a String.
    def html_truncate(text, options = {})
      options[:max_length] = options.delete(:length) || options[:max_length]
      options[:tail] = options.delete(:separator) || options[:tail] || "..."
      options[:count_tags] ||= false
      options[:count_tail] ||= false
      options[:tail_before_final_tag] ||= true

      Truncato.truncate(text, options)
    end

    def present(object)
      presenter = "#{object.class.name}Presenter".constantize.new(object)

      yield(presenter) if block_given?

      presenter
    end

    # Generates a link to be added to the global Edit link so admins
    # can easily manage data without having to look for it at the admin
    # panel when they're at a public page.
    #
    # link          - The String with the URL.
    # action        - The Symbol action to check the permissions for.
    # subject       - The Symbol subject to perform the action to.
    # extra_context - An optional Hash to check the permissions.
    #
    # Returns nothing.
    def edit_link(link, action, subject, extra_context = {})
      return unless current_user
      return unless admin_allowed_to?(action, subject, extra_context)
      return if content_for?(:edit_link)

      content_for(:edit_link, link)
    end
  end
end
