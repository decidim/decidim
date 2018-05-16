# frozen-string_literal: true

module Decidim
  module Initiatives
    class MilestoneCompletedEvent < Decidim::Events::SimpleEvent
      i18n_attributes :percentage

      def percentage
        extra[:percentage]
      end

      def participatory_space
        resource
      end
    end
  end
end
