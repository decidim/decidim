# frozen_string_literal: true

module Decidim
  module Elections
    class Vote < Elections::ApplicationRecord
      belongs_to :question, class_name: "Decidim::Elections::Question"
      belongs_to :response_option, class_name: "Decidim::Elections::ResponseOption", counter_cache: true

      # TODO: validate voter_uid per election
      # TODO: validate number of response options per question type
    end
  end
end
