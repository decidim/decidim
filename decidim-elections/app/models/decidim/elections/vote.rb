# frozen_string_literal: true

module Decidim
  module Elections
    class Vote < Elections::ApplicationRecord
      belongs_to :voter, class_name: "Decidim::Elections::Voter", foreign_key: :decidim_elections_voter_id, optional: true
      belongs_to :user, class_name: "Decidim::User", foreign_key: :decidim_user_id, optional: true
      belongs_to :question, class_name: "Decidim::Elections::Question", foreign_key: :decidim_elections_question_id
      belongs_to :response_option, class_name: "Decidim::Elections::ResponseOption", foreign_key: :decidim_elections_response_option_id, counter_cache: true

      validates :voter_uid, uniqueness: { scope: :decidim_elections_question_id }
    end
  end
end
