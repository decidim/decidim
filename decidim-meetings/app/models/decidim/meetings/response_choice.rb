# frozen_string_literal: true

module Decidim
  module Meetings
    class ResponseChoice < Meetings::ApplicationRecord
      belongs_to :response,
                 class_name: "Decidim::Meetings::Response",
                 foreign_key: "decidim_response_id",
                 inverse_of: :choices

      belongs_to :response_option,
                 class_name: "Decidim::Meetings::ResponseOption",
                 foreign_key: "decidim_response_option_id",
                 inverse_of: :choices
    end
  end
end
