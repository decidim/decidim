# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # Common logic to build form objects
  module FormFactory
    extend ActiveSupport::Concern

    included do
      def form(klass)
        Class.new do
          def initialize(klass, context)
            @klass = klass
            @context = context
          end

          def instance
            @klass.new
          end

          def from_model(params)
            @klass.from_model(params)
          end

          def from_params(params, context = {})
            @klass.from_params(params, context_hash.merge(context))
          end

          def context_hash
            {
              current_organization: @context.current_organization,
              current_user: @context.current_user
            }
          end
        end.new(klass, self)
      end
    end
  end
end
