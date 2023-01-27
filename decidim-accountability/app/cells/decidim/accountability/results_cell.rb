# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Accountability
    # This cell renders a list of results
    class ResultsCell < Decidim::ViewModel
      include Decidim::CardHelper

      alias results model

      def turbo_frame
        @turbo_frame ||= options[:turbo_frame] || "project_frame"
      end
    end
  end
end
