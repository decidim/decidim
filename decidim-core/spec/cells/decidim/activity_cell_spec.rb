# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActivityCell, type: :cell do
  subject { my_cell.call }

  let(:cell_name) { "decidim/activity" }
  let(:my_cell) { cell(cell_name, model) }
  let(:model) do
    create(:action_log, action: "publish", visibility: "all", resource: resource, organization: component.organization, participatory_space: component.participatory_space)
  end
  let(:component) do
    create(:component, :published)
  end
  let(:resource) do
    create(:dummy_resource, component: component, published_at: published_at)
  end
  let(:published_at) { Time.current }

  describe "user" do
    subject { described_class.new(model) }

    let(:author) { create(:user, organization: component.organization) }

    context "when the author is a user group" do
      before do
        resource.author = author
        resource.user_group = create(:user_group, :verified, organization: component.organization, users: [author])
        resource.save!
      end

      it "returns the user group" do
        expect(subject.user).to eq(resource.user_group)
      end
    end

    context "when the author is a user" do
      before do
        resource.author = author
        resource.save!
      end

      it "returns the user" do
        expect(subject.user).to eq(resource.author)
      end
    end
  end

  describe "renderable?" do
    subject { described_class.new(model) }

    context "when the resource is published" do
      it { is_expected.to be_renderable }
    end

    context "when the resource is not published" do
      let(:published_at) { nil }

      it { is_expected.not_to be_renderable }
    end

    context "when there's no resource" do
      before do
        resource.delete
      end

      it { is_expected.not_to be_renderable }
    end

    context "when there's no participatory space" do
      before do
        component.participatory_space.delete
      end

      it { is_expected.not_to be_renderable }
    end
  end

  describe "#cache_hash" do
    subject { described_class.new(model, context: { controller: controller, show_author: show_author }) }

    let(:controller) { double }
    let(:show_author) { false }

    before do
      allow(controller).to receive(:current_user).and_return(nil)
      allow(controller).to receive(:redesigned_layout).with(:cell_name).and_return(cell_name)
      allow(controller).to receive(:redesigned_layout) do |name|
        name
      end
    end

    context "when the author is shown" do
      let(:show_author) { true }

      context "and the user is updated" do
        let!(:original_hash) { subject.send(:cache_hash) }

        before do
          # rubocop:disable Rails/SkipsModelValidations
          resource.normalized_author.touch
          # rubocop:enable Rails/SkipsModelValidations

          subject.user.reload
        end

        it "changes the cache hash" do
          expect(subject.send(:cache_hash)).not_to eq(original_hash)
        end
      end
    end

    context "when the author is hidden" do
      context "and the user is updated" do
        let!(:original_hash) { subject.send(:cache_hash) }

        before do
          # rubocop:disable Rails/SkipsModelValidations
          resource.normalized_author.touch
          # rubocop:enable Rails/SkipsModelValidations

          subject.user.reload
        end

        it "does not change the cache hash" do
          expect(subject.send(:cache_hash)).to eq(original_hash)
        end
      end
    end
  end
end
