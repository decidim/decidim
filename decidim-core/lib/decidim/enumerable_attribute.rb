# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module EnumerableAttribute
    extend ActiveSupport::Concern

    included do
      # Adds custom enum functionality, aiming to allow generation and composition of scopes
      # This is generated as a a result of refactor of existing implementations, and does not aim
      # to implement or override Rails's default ENUM, as being desctribed in
      # https://api.rubyonrails.org/v7.0/classes/ActiveRecord/Enum.html
      # Maybe at a later stage, we could fully migrate to Rails enum.
      #
      # Possible options using this method:
      # prepend_scope: Allows you to combine scopes that would be injected to main scope:
      #
      #                enum_fields :database_field, %w(value), prepend_scope: [:published, :active]
      #
      #                This is equivalent of:
      #                scope value, -> { published.active.where(database_field: "value") }
      #
      # method_suffix: allows you to append a string to the boolean generated method following this
      #
      #                enum_fields :database_field, %w(value), method_suffix: :suffix
      #
      #                And this will generate dynamic methods like
      #                def value_suffix?
      #                  :database_field == "value"
      #                end
      #
      # enable_scopes: Allows you to disable scope generation like
      #
      #                enum_fields :database_field, %w(value), enable_scopes: false
      #
      def self.enum_fields(stateable, possible_states, options = {})
        default_options = { enable_scopes: true }
        options = options.reverse_merge(default_options)

        possible_states.each do |state|
          boolean_method = [state]
          boolean_method.push(options[:method_suffix]) if options[:method_suffix]

          if options[:enable_scopes]
            scope "not_#{state}".to_sym, -> { where.not(stateable => state) }
            scope state.to_s.to_sym, lambda {
              if options[:prepend_scope]
                options[:prepend_scope].inject(self, :send).where(stateable => state)
              else
                where(stateable => state)
              end
            }
          end

          define_method("#{boolean_method.join("_")}?") do
            send(stateable) == state.to_s
          end
        end
      end
    end
  end
end
