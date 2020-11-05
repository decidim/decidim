# frozen_string_literal: true

module Decidim
  module Elections
    # Custom helpers for election cells.
    #
    module ElectionCellsHelper
      include PaginateHelper
      include Decidim::Comments::CommentsHelper
    end
  end
end
