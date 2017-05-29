# frozen_string_literal: true

module Decidim
  module ReplaceButtonsHelper
    # Overrides the submit tags to always be buttons instead of inputs.
    # Buttons are much more stylable and less prone to bugs.
    #
    # value   - The text of the button
    # options - Options to provide to the actual tag.
    #
    # Returns a SafeString with the tag.
    def submit_tag(text = "Save changes", options = {})
      options = options.stringify_keys

      content_tag :button, text, { "type" => "submit", "name" => "commit" }.update(options)
    end

    # Public: Overrides button_to so it always renders buttons instead of
    # input tags.
    #
    # arguments - The same arguments that would be sent to `button_to`.
    # block     - An optional block to be sent.
    #
    # Returns a button.
    def button_to(*arguments, &block)
      if block_given?
        body = block
        url = arguments[0]
        html_options = arguments[1] || {}
      else
        body = arguments[0]
        url = arguments[1]
        html_options = arguments[2] || {}
      end

      if block_given?
        super(url, html_options, &body)
      else
        super(url, html_options) { body }
      end
    end
  end
end
