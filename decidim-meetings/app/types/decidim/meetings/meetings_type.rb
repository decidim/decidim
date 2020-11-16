# frozen_string_literal: true

module Decidim
  module Meetings
    class MeetingsType < GraphQL::Schema::Object
      graphql_name "Meetings"
      implements Decidim::Core::ComponentInterface

      description "A meetings component of a participatory space."

      connection :meetings, MeetingType.connection_type do
        resolve ->(component, _args, _ctx) {
                  MeetingsTypeHelper.base_scope(component).includes(:component)
                }
      end

      field(:meeting, MeetingType) do
        argument :id, !types.ID

        resolve ->(component, args, _ctx) {
          MeetingsTypeHelper.base_scope(component).find_by(id: args[:id])
        }
      end
    end

    module MeetingsTypeHelper
      def self.base_scope(component)
        Meeting.visible.where(component: component)
      end
    end
  end
end
