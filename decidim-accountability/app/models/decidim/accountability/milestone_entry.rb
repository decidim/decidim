# frozen_string_literal: true

module Decidim
  module Accountability
    # The data store for a MilestoneEntry for a Result in the Decidim::Accountability component.
    # It stores a date, and localized description.
    class MilestoneEntry < Accountability::ApplicationRecord
      include Decidim::TranslatableResource
      include Decidim::Traceable

      translatable_fields :title
      translatable_fields :description
      belongs_to :result, foreign_key: "decidim_accountability_result_id", class_name: "Decidim::Accountability::Result", inverse_of: :milestones

      def self.log_presenter_class_for(_log)
        Decidim::Accountability::AdminLog::MilestoneEntryPresenter
      end
    end
  end
end
