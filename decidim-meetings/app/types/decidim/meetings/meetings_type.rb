# frozen_string_literal: true

module Decidim
  module Meetings
    class MeetingsType < GraphQL::Schema::Object
      graphql_name "Meetings"
      implements Decidim::Core::ComponentInterface

      description "A meetings component of a participatory space."

      field :meetings, MeetingType.connection_type, null: false, connection: true do
        def resolve(component, _args, _ctx)
          MeetingsTypeHelper.base_scope(component).includes(:component)
        end
      end

      field(:meeting, MeetingType, null: false) do
        argument :id, ID, required: true

        def resolve(component, args, _ctx)
          MeetingsTypeHelper.base_scope(component).find_by(id: args[:id])
        end
      end
    end

    module MeetingsTypeHelper
      def self.base_scope(component)
        Meeting.visible.where(component: component)
      end
    end
  end
end
