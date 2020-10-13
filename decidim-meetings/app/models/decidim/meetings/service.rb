# frozen_string_literal: true

module Decidim
  module Meetings
    class Service < Meetings::ApplicationRecord
      include Decidim::Traceable
      include Decidim::TranslatableResource

      translatable_fields :title, :description
      belongs_to :meeting, foreign_key: "decidim_meeting_id", class_name: "Decidim::Meetings::Meeting"
    end
  end
end
