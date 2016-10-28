# frozen_string_literal: true
module Decidim
  class PromotedProcesses < Rectify::Query
    def query
      ParticipatoryProcess.where(promoted: true)
    end
  end
end
