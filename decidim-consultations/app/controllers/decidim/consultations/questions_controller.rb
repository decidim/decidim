# frozen_string_literal: true

module Decidim
  module Consultations
    # A controller that holds the logic to show questions in a
    # public layout.
    class QuestionsController < Decidim::Consultations::ApplicationController
      layout "layouts/decidim/question"

      include NeedsQuestion

      helper Decidim::SanitizeHelper
      helper Decidim::IconHelper
      helper Decidim::Comments::CommentsHelper
      helper Decidim::AttachmentsHelper
      helper Decidim::ResourceReferenceHelper
      helper Decidim::ActionAuthorizationHelper

      def show
        enforce_permission_to :read, :question, question: current_question
      end
    end
  end
end
