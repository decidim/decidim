# frozen_string_literal: true

module Decidim
  module Results
    # Custom helpers, scoped to the meetings engine.
    #
    module ApplicationHelper
      include PaginateHelper
      include Decidim::Comments::CommentsHelper
    end
  end
end
