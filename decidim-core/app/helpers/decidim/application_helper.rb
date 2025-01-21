# frozen_string_literal: true

module Decidim
  # Main module to add application-wide helpers.
  module ApplicationHelper
    include Decidim::OmniauthHelper
    include Decidim::ContextualHelpHelper
    include Decidim::AmendmentsHelper
    include Decidim::CacheHelper

    def layout_item_classes
      "layout-item"
    end

    # Truncates a given text respecting its HTML tags.
    #
    # text    - The String text to be truncated.
    # options - A Hash with the options to truncate the text (default: {}):
    #           :length - An Integer number with the max length of the text.
    #           :separator - A String to append to the text when it is being
    #           truncated.
    #
    # Returns a String.
    def html_truncate(text, options = {})
      options[:max_length] = options.delete(:length) || options[:max_length]
      options[:tail] = options.delete(:separator) || options[:tail] || "…"
      options[:count_tags] ||= false
      options[:count_tail] ||= false
      options[:tail_before_final_tag] = true unless options.has_key?(:tail_before_final_tag)

      Decidim::HtmlTruncation.new(text, options).perform
    end

    def present(object, presenter_class: nil)
      presenter_class ||= resolve_presenter_class(object, presenter_class:)
      presenter = presenter_class.new(object)

      yield(presenter) if block_given?

      presenter
    end

    def resolve_presenter_class(object, presenter_class: nil)
      presenter_class || "#{object.class.name}Presenter".constantize
    rescue StandardError
      ::Decidim::NilPresenter
    end

    # Generates a link to be added to the global Edit link so admins
    # can easily manage data without having to look for it at the admin
    # panel when they are at a public page.
    #
    # link_url      - The String with the URL.
    # action        - The Symbol action to check the permissions for.
    # subject       - The Symbol subject to perform the action to.
    # extra_context - An optional Hash to check the permissions.
    # link_options   - An optional Hash to change the default name and icon link.
    # link_options[:name]   - An optional String to be used as the label of the link.
    # link_options[:icon]   - An optional String with the identifier name of the icon.
    # link_options[:class]  - An optional String to add as a css class to the link wrapper.
    #
    # Returns nothing.
    def edit_link(link_url, action, subject, extra_context = {}, link_options = {})
      return unless current_user
      return unless admin_allowed_to?(action, subject, extra_context)
      return if content_for?(:edit_link)

      cell_html = raw(cell("decidim/navbar_admin_link", link_url:, link_options:))
      content_for(:edit_link, cell_html)
    end

    # Generates a second link to be added to the global admin action link so admins
    # can easily manage data without having to look for it at the admin
    # panel when they are at a public page.
    #
    # link_url       - The String with the URL.
    # action         - The Symbol action to check the permissions for.
    # subject        - The Symbol subject to perform the action to.
    # extra_context  - An optional Hash to check the permissions.
    # link_options   - An optional Hash to change the default name and icon link.
    # link_options[:name]   - An optional String to be used as the label of the link.
    # link_options[:icon]   - An optional String with the identifier name of the icon.
    # link_options[:class]  - An optional String to add as a css class to the link wrapper.
    #
    # Returns nothing.
    def extra_admin_link(link_url, action, subject, extra_context = {}, link_options = {})
      return unless current_user
      return unless admin_allowed_to?(action, subject, extra_context)
      return if content_for?(:extra_admin_link)

      cell_html = raw(cell("decidim/navbar_admin_link", link_url:, link_options:))
      content_for(:extra_admin_link, cell_html)
    end

    # Public: Overwrites the `cell` helper method to automatically set some
    # common context.
    #
    # name - the name of the cell to render
    # model - the cell model
    # options - a Hash with options
    #
    # Renders the cell contents.
    def cell(name, model, options = {}, &)
      options = { context: { view_context: self, current_user: } }.deep_merge(options)
      super
    end

    def prevent_timeout_seconds
      0
    end

    def text_initials(name)
      name.split(/[\s.]+/).map(&:chr).slice(0, 2).join.upcase
    end

    def add_body_classes(*class_names)
      content_for :body_class, class_names.map { |class_name| " #{class_name.strip}" }.join
    end
  end
end
