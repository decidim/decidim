# frozen_string_literal: true

module Decidim
  module Accountability
    class ResultProgressUpdatedEvent < BaseResultEvent
      i18n_attributes :progress

      def progress
        extra[:progress]
      end
    end
  end
end
