# frozen_string_literal: true

module Decidim
  #
  # This class handles all logic regarding deprecated methods.
  #
  module Deprecations
    # Define a deprecated alias for a method
    #
    # @param [Symbol] old_name - name of the method to deprecate
    # @param [Symbol] replacement - name of the new method to use
    def deprecated_alias(old_name, replacement)
      define_method(old_name) do |*args, &block|
        Decidim.deprecator.warn "##{old_name} deprecated (please use ##{replacement})"
        send replacement, *args, &block
      end
    end
  end
end
