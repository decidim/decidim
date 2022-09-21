# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Accountability
    # This cell renders a list of results
    class ResultsCell < Decidim::ViewModel
      include ApplicationHelper
      include ActiveSupport::NumberHelper

      delegate :component_settings, to: :controller

      alias results model
    end
  end
end
