# frozen_string_literal: true

module Decidim
  module Debates
    # Custom helpers for debates cells.
    #
    module DebateCellsHelper
      include PaginateHelper
      include Decidim::Comments::CommentsHelper
    end
  end
end
