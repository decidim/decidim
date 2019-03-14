# frozen_string_literal: true

module Decidim
  # Main module to add application-wide helpers.
  module ApplicationHelper
    include Decidim::OmniauthHelper
    include Decidim::ScopesHelper
    include Decidim::ContextualHelpHelper
    include Decidim::AmendmentsHelper

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

    def translated_in_current_locale(attribute)
      return if attribute.nil?

      attribute[I18n.locale.to_s].present?
    end

    def present(object, presenter_class: nil)
      presenter_class ||= "#{object.class.name}Presenter".constantize
      presenter = presenter_class.new(object)

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

    # Public: Overwrites the `cell` helper method to automatically set some
    # common context.
    #
    # name - the name of the cell to render
    # model - the cell model
    # options - a Hash with options
    #
    # Renders the cell contents.
    def cell(name, model, options = {}, &block)
      options = { context: { current_user: current_user } }.deep_merge(options)

      super(name, model, options, &block)
    end
  end
end
