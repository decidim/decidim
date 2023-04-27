# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module EnumerableAttribute
    extend ActiveSupport::Concern

    included do
      def self.enum_fields(_stateable, possible_states, options = {})
        default_options = { enable_scopes: true }
        options = options.reverse_merge(default_options)

        possible_states.each do |state|
          if options[:enable_scopes]
            scope "not_#{state}".to_sym, lambda {
              raise "scope not_#{state} has been called"
            }

            scope state.to_s.to_sym, lambda {
              raise "scope #{state} has been called"
            }
          end
        end
      end
    end
  end
end
