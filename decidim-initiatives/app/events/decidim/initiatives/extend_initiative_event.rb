# frozen-string_literal: true

module Decidim
  module Initiatives
    class ExtendInitiativeEvent < Decidim::Events::SimpleEvent
      def participatory_space
        resource
      end
    end
  end
end
