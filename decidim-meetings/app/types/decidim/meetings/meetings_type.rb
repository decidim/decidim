# frozen_string_literal: true

module Decidim
  module Meetings
    MeetingsType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Core::ComponentInterface }]

      name "Meetings"
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
