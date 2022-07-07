# frozen_string_literal: true

module Decidim
  module Accountability
    # The data store for a Status in the Decidim::Accountability component. It stores a
    # key, a localized name, a localized description and and associated progress number.
    class Status < Accountability::ApplicationRecord
      include Decidim::HasComponent
      include Decidim::TranslatableResource
      include Decidim::FilterableResource
      include Decidim::Traceable

      component_manifest_name "accountability"

      translatable_fields :name, :description

      has_many :results, foreign_key: "decidim_accountability_status_id", class_name: "Decidim::Accountability::Result", inverse_of: :status, dependent: :nullify

      validates :key, presence: true, uniqueness: { scope: :decidim_component_id }
      validates :name, presence: true

      # Allow ransacker to search for a key in a hstore column (`name`.`en`)
      ransacker_i18n :name

      def self.log_presenter_class_for(_log)
        Decidim::Accountability::AdminLog::StatusPresenter
      end
    end
  end
end
