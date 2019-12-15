# frozen_string_literal: true

module Decidim
  module Core
    module HasPublishableInputSort
      def self.included(child_class)
        child_class.argument :publishedAt, String, "Sort by date of publication, valid values are ASC or DESC", required: false
        # child_class.argument :createdAt, String, "Sort by date of creation, valid values are ASC or DESC", required: false
        # child_class.argument :updatedAt, String, "Sort by date of last modification, valid values are ASC or DESC", required: false
      end
    end
  end
end
