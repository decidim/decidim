# frozen_string_literal: true

module Decidim
  module Meetings
    class DiffRenderer < BaseDiffRenderer
      def attribute_types
        {
          title: :i18n,
          description: :i18n_html,
          address: :string,
          location: :i18n,
          location_hints: :i18n,
          start_time: :date,
          end_time: :date,
          decidim_scope_id: :scope
        }
      end
    end
  end
end
