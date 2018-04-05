# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # Custom helpers, scoped to the meetings admin engine.
      #
      module ApplicationHelper
        include Decidim::MapHelper

        MEETING_PUBLIC_TYPES = %w(public private other).freeze
        MEETING_OPEN_TYPES = %w(open close other).freeze
        MEETING_TRANSPARENT_TYPES = %w(transparent opaque other).freeze

        def meeting_open_types_for_select
          MEETING_OPEN_TYPES.map do |type|
            [
              I18n.t("meeting_open_types.#{type}", scope: "decidim.meetings"),
              type
            ]
          end
        end

        def meeting_public_types_for_select
          MEETING_PUBLIC_TYPES.map do |type|
            [
              I18n.t("meeting_public_types.#{type}", scope: "decidim.meetings"),
              type
            ]
          end
        end

        def meeting_transparent_types_for_select
          MEETING_TRANSPARENT_TYPES.map do |type|
            [
              I18n.t("meeting_transparent_types.#{type}", scope: "decidim.meetings"),
              type
            ]
          end
        end
      end
    end
  end
end
