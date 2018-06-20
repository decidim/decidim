# frozen_string_literal: true

module Decidim
  module Meetings
    MeetingMetricType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Meetings::MeetingMetricInterface }]

      name "MeetingMetricType"
      description "A meeting component of a participatory space."

      field :count, !types.Int, "Total meetings" do
        resolve ->(organization, _args, _ctx) {
          MeetingMetricTypeHelper.base_scope(organization).count
        }
      end

      field :data, !types[MeetingMetricObjectType], "Data for each meeting" do
        resolve ->(organization, _args, _ctx) {
          MeetingMetricTypeHelper.base_scope(organization)
        }
      end
    end

    module MeetingMetricTypeHelper
      def self.base_scope(_organization)
        # super(organization).accepted
        Meeting.all
      end
    end
  end
end
