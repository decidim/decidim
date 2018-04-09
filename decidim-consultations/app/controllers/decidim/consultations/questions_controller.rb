# frozen_string_literal: true

module Decidim
  module Consultations
    # A controller that holds the logic to show questions in a
    # public layout.
    class QuestionsController < Decidim::ApplicationController
      layout "layouts/decidim/question"

      include NeedsQuestion

      helper Decidim::SanitizeHelper
      helper Decidim::IconHelper
      helper Decidim::Comments::CommentsHelper
      helper Decidim::AttachmentsHelper
      helper Decidim::ResourceReferenceHelper

      def show
        authorize! :read, current_question
      end
    end
  end
end
