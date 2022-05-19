# frozen_string_literal: true

module Decidim
  module Accountability
    # The data store for a TimelineEntry for a Result in the Decidim::Accountability component.
    # It stores a date, and localized description.
    class TimelineEntry < Accountability::ApplicationRecord
      include Decidim::TranslatableResource

      translatable_fields :title
      translatable_fields :description
      belongs_to :result, foreign_key: "decidim_accountability_result_id", class_name: "Decidim::Accountability::Result", inverse_of: :timeline_entries
    end
  end
end
