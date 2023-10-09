# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ResourceHelper do
    let(:component) { create(:component) }
    let(:resource) { create(:dummy_resource, component:) }

    describe "linked_classes_for" do
      subject { helper.linked_classes_for(DummyResources::DummyResource) }

      context "when it is not resourceable" do
        before do
          allow(DummyResources::DummyResource)
            .to receive(:respond_to?)
            .with(:linked_classes_for)
            .and_return(false)
        end

        it { is_expected.to eq [] }
      end

      context "when it is resourceable" do
        before do
          allow(helper)
            .to receive(:current_component)
            .and_return(component)
          allow(DummyResources::DummyResource)
            .to receive(:linked_classes_for)
            .and_return(["Decidim::Meetings::Meeting"])
        end

        it "formats the linked classes with underscore name and name" do
          expect(subject).to eq [["decidim/meetings/meeting", "<span>Meetings</span>"]]
        end
      end
    end

    describe "linked_classes_filter_values_for" do
      subject { helper.linked_classes_filter_values_for(DummyResources::DummyResource) }

      before do
        allow(helper)
          .to receive(:linked_classes_for)
          .and_return([["decidim/meetings/meeting", "<span>Meetings</span>"]])
      end

      it "formats the values for the form" do
        expect(subject).to eq [["", "<span>All</span>"], ["decidim/meetings/meeting", "<span>Meetings</span>"]]
      end
    end

    describe "resource_locator" do
      subject { helper.resource_locator(resource) }

      it { is_expected.to be_an_instance_of(ResourceLocatorPresenter) }
    end
  end
end
