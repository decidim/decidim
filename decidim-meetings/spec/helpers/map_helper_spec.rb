# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe MapHelper do
      describe "event_pin_color" do
        context "when organization group_highlight_enabled is true" do
          let(:colors) do
            {
              primary: "#ef604d",
              group_highlight_color: "#ff0000",
              citizen_highlight_color: "#0000ff",
              official_highlight_color: "#00ff00"
            }
          end
          let(:organization) { create(:organization, group_highlight_enabled: true, colors: colors) }
          let(:component) { create(:component, manifest_name: "meetings", organization: organization) }

          it "returns official specified color" do
            meeting = create(:meeting, component: component)
            expect(helper.event_pin_color(meeting)).to eq("#00ff00")
          end

          it "returns citizen specified color" do
            meeting = create(:meeting, :not_official, component: component)
            expect(helper.event_pin_color(meeting)).to eq("#0000ff")
          end

          it "returns group specified color" do
            meeting = create(:meeting, :with_user_group_author, component: component)
            expect(helper.event_pin_color(meeting)).to eq("#ff0000")
          end
        end

        context "when organization group_highlight_enabled is false" do
          it "returns the primary color" do
            component = create(:component, manifest_name: "meetings")
            meeting = create(:meeting, component: component)

            expect(helper.event_pin_color(meeting)).to eq(component.organization.colors[:primary])
          end
        end
      end
    end
  end
end
