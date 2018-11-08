# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe CalendarRenderer do
    subject { described_class }

    let(:component) { create :component, manifest_name: "meetings" }
    let(:organization) { component.organization }
    let(:dummy_resource) { create :dummy_resource }

    describe "when the resource is a component" do
      it "calls the ComponentCalendar" do
        expect(Calendar::ComponentCalendar).to receive(:for)
        subject.for(component)
      end
    end

    describe "when the resource is aan organization" do
      it "calls the OrganizationCalendar" do
        expect(Calendar::OrganizationCalendar).to receive(:for)
        subject.for(organization)
      end
    end

    describe "when the resource is something else" do
      it "does nothing" do
        expect(subject.for(dummy_resource)).to be_nil
      end
    end
  end
end
