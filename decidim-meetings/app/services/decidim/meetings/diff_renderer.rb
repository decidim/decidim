# frozen_string_literal: true

module Decidim
  module Meetings
    class DiffRenderer < BaseDiffRenderer
      def attribute_types
        {
          title: :string,
          description: :html,
          address: :string,
          location: :string,
          location_hints: :string,
          start_time: :date,
          end_time: :date,
          decidim_user_group_id: :user_group,
          decidim_scope_id: :scope
        }
      end
    end
  end
end
