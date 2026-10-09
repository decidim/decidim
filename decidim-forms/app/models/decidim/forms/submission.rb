# frozen_string_literal: true

module Decidim
  module Forms
    # One participant's complete set of responses to a questionnaire.
    class Submission < Forms::ApplicationRecord
      belongs_to :questionnaire, class_name: "Questionnaire", foreign_key: "decidim_questionnaire_id", inverse_of: :submissions
      belongs_to :user, class_name: "Decidim::User", foreign_key: "decidim_user_id", optional: true
      has_many :responses, class_name: "Response", foreign_key: "decidim_submission_id", dependent: :destroy, inverse_of: :submission
    end
  end
end
