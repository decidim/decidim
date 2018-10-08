# frozen_string_literal: true

require "spec_helper"

describe Decidim::ContentBlocks::LastActivityCell, type: :cell do
  let(:organization) { create(:organization) }

  controller Decidim::PagesController

  before do
    allow(controller).to receive(:current_organization).and_return(organization)
  end

  Decidim::ActivitySearch.class_eval do
    def resource_types
      %w(
        Decidim::DummyResources::DummyResource
      )
    end
  end

  describe "valid_activities" do
    subject { cell.valid_activities }

    let(:cell) do
      described_class.new(nil, activities_count: 3)
    end
    let!(:action_log) do
      create(:action_log, action: "publish", visibility: "all", resource: resource, organization: organization)
    end
    let(:component) do
      create(:component, :published, organization: organization)
    end
    let(:resource) do
      create(:dummy_resource, component: component, published_at: Time.current)
    end

    before do
      allow(cell).to receive(:controller).and_return(controller)
    end

    it { is_expected.to include(action_log) }

    context "when the participatory space is missing" do
      before do
        action_log.participatory_space.delete
      end

      it { is_expected.not_to include(action_log) }
    end

    context "when the resource is missing" do
      before do
        resource.delete
      end

      it { is_expected.not_to include(action_log) }
    end

    context "with a lot of activities" do
      before do
        5.times do
          dummy_resource = create(:dummy_resource, component: component, published_at: Time.current)
          create(:action_log, action: "publish", visibility: "all", resource: dummy_resource, organization: organization)
        end
      end

      it "limits the results" do
        expect(subject.length).to eq(3)
      end
    end
  end
end
