# frozen_string_literal: true

module Decidim
  module Meetings
    class MeetingsType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::ComponentInterface

      graphql_name "Meetings"
      description "A meetings component of a participatory space."

      field :meetings, MeetingType.connection_type, null: true, connection: true

      def meetings
        MeetingsTypeHelper.base_scope(object).includes(:component)
      end

      field :meeting, MeetingType, null: true do
        argument :id, ID, required: true
      end

      def meeting(**args)
        MeetingsTypeHelper.base_scope(object).find_by(id: args[:id])
      end
    end

    module MeetingsTypeHelper
      def self.base_scope(component)
        Meeting.visible.where(component: component)
      end
    end
  end
end
