# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Accountability
    # This cell renders a list of results
    class ResultsCell < Decidim::ViewModel
      alias results model
    end
  end
end
