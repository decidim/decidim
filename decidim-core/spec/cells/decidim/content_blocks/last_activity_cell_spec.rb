# frozen_string_literal: true

require "spec_helper"

describe Decidim::ContentBlocks::LastActivityCell, type: :cell do
  subject { cell.valid_activities }

  let(:organization) { create(:organization) }
  let(:component) do
    create(:component, :published, organization:)
  end
  let(:cell) do
    described_class.new(nil, activities_count: 3)
  end

  controller Decidim::PagesController

  before do
    allow(Decidim::ActionLog).to receive(:public_resource_types).and_return(
      %w(Decidim::DummyResources::DummyResource)
    )
    allow(Decidim::ActionLog).to receive(:publicable_public_resource_types).and_return(
      %w(Decidim::DummyResources::DummyResource)
    )

    allow(cell).to receive(:controller).and_return(controller)
  end

  describe "valid_activities" do
    let!(:action_log) do
      create(:action_log, action: "publish", visibility: "all", resource:, organization:)
    end
    let(:resource) do
      create(:dummy_resource, component:, published_at: Time.current)
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

    context "when the resource has been hidden" do
      before do
        create(:moderation, :hidden, reportable: action_log.resource)
      end

      it { is_expected.not_to include(action_log) }
    end

    context "with a lot of activities" do
      before do
        5.times do
          dummy_resource = create(:dummy_resource, component:, published_at: Time.current)
          create(:action_log, action: "publish", visibility: "all", resource: dummy_resource, organization:)
        end
      end

      it "limits the results" do
        expect(subject.length).to eq(3)
      end
    end
  end

  describe "#cache_hash" do
    let!(:action_log) do
      create(:action_log, action: "publish", visibility: "all", resource:, organization:)
    end
    let(:resource) do
      create(:dummy_resource, component:, published_at: Time.current)
    end

    it "generate a unique hash" do
      old_hash = cell.send(:cache_hash)

      expect(cell.send(:cache_hash)).to eq(old_hash)
    end

    context "when new valid activity" do
      it "generates a different hash" do
        old_hash = cell.send(:cache_hash)
        activities = [action_log, create(:action_log, action: "publish", visibility: "all", resource:, organization:)]
        allow(cell).to receive(:valid_activities).and_return(activities)

        expect(cell.send(:cache_hash)).not_to eq(old_hash)
      end
    end

    context "when switching locale" do
      let(:alt_locale) { :ca }

      before do
        allow(I18n).to receive(:locale).and_return(alt_locale)
      end

      it "generates a different hash" do
        expect(cell.send(:cache_hash)).not_to match(/en$/)
      end
    end
  end
end
