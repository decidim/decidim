# frozen_string_literal: true

module Decidim
  module Elections
    # This cell renders the questions preview
    # for a given instance of an Election
    class ElectionPreviewCell < Decidim::ViewModel
      def show
        render unless model.finished?
      end
    end
  end
end
