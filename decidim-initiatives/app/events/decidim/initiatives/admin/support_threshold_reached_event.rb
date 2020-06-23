# frozen-string_literal: true

module Decidim
  module Initiatives
    module Admin
      class SupportThresholdReachedEvent < Decidim::Events::SimpleEvent
        def participatory_space
          resource
        end
      end
    end
  end
end
