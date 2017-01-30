# frozen_string_literal: true
module Decidim
  module Results
    # The data store for a Result in the Decidim::Results component. It stores a
    # title, description and any other useful information to render a custom result.
    class Result < Results::ApplicationRecord
      include Decidim::Resourceable
      include Decidim::HasFeature
      include Decidim::HasScope
      include Decidim::HasCategory
    end
  end
end
