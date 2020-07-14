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

    def present(object, presenter_class: nil)
      presenter_class ||= resolve_presenter_class(object, presenter_class: presenter_class)
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
    # panel when they're at a public page.
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
    def edit_link(link_url, action, subject, extra_context = {}, link_options = { class: "topbar__edit__link" })
      return unless current_user
      return unless admin_allowed_to?(action, subject, extra_context)
      return if content_for?(:edit_link)

      cell_html = raw(cell("decidim/navbar_admin_link", link_url: link_url, link_options: link_options))
      content_for(:edit_link, cell_html)
    end

    # Generates a second link to be added to the global admin action link so admins
    # can easily manage data without having to look for it at the admin
    # panel when they're at a public page.
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

      cell_html = raw(cell("decidim/navbar_admin_link", link_url: link_url, link_options: link_options))
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
    def cell(name, model, options = {}, &block)
      options = { context: { current_user: current_user } }.deep_merge(options)

      super(name, model, options, &block)
    end

    # Public: Builds the URL for the step Call To Action. Takes URL params
    # into account.
    #
    # process - a ParticipatoryProcess
    #
    # Returns a String that can be used as a URL.
    def step_cta_url(process)
      return unless respond_to?(:decidim_participatory_processes)

      base_url, params = decidim_participatory_processes.participatory_process_path(process).split("?")

      if params.present?
        [base_url, "/", process.active_step.cta_path, "?", params].join("")
      else
        [base_url, "/", process.active_step.cta_path].join("")
      end
    end
  end
end
