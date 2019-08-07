# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActivityCell, type: :cell do
  subject { my_cell.call }

  let(:my_cell) { cell("decidim/activity", model) }
  let(:model) do
    create(:action_log, action: "publish", visibility: "all", resource: resource, organization: component.organization, participatory_space: component.participatory_space)
  end
  let(:component) do
    create(:component, :published)
  end
  let(:resource) do
    create(:dummy_resource, component: component, published_at: published_at)
  end

  describe "renderable?" do
    subject { described_class.new(model) }

    context "when the resource is published" do
      let(:published_at) { Time.current }

      it { is_expected.to be_renderable }
    end

    context "when the resource is not published" do
      let(:published_at) { nil }

      it { is_expected.not_to be_renderable }
    end

    context "when there's no resource" do
      let(:published_at) { Time.current }

      before do
        resource.delete
      end

      it { is_expected.not_to be_renderable }
    end

    context "when there's no participatory space" do
      let(:published_at) { Time.current }

      before do
        component.participatory_space.delete
      end

      it { is_expected.not_to be_renderable }
    end
  end
end
