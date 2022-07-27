# frozen_string_literal: true

module Decidim
  # A heper to expose an easy way to add authorization forms in a view.
  module AuthorizationFormHelper
    # Creates a ew authorization form in a view, accepts the same arguments as
    # `form_for`.
    #
    # record  - The record to use in the form, it shoulde be a descendant of
    # AuthorizationHandler.
    # options - An optional hash with options to pass wo the form builder.
    # block   - A block with the content of the form.
    #
    # Returns a String.
    def authorization_form_for(record, options = {}, &)
      default_options = {
        builder: AuthorizationFormBuilder,
        as: "authorization_handler",
        url: decidim_verifications.authorizations_path
      }

      options = default_options.merge(options)
      decidim_form_for(record, options, &)
    end
  end
end
