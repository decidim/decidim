# frozen_string_literal: true
module Decidim
  # A heper to expose an easy way to add authorization forms in a view.
  module DecidimFormHelper
    # A custom form for that injects client side validations with Abide.
    #
    # record - The object to build the form for.
    # options - A Hash of options to pass to the form builder.
    # &block - The block to execute as content of the form.
    #
    # Returns a String.
    def decidim_form_for(record, options = {}, &block)
      options[:data] ||= {}
      options[:data].update(abide: true, "live-validate" => true, "validate-on-blur" => true)
      form_for(record, options, &block)
    end
  end
end
