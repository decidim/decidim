# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActivityCell, type: :cell do
  subject { my_cell.call }

  let(:cell_name) { "decidim/activity" }
  let(:my_cell) { cell(cell_name, model) }
  let(:model) do
    create(:action_log, action: "publish", visibility: "all", resource:, organization: component.organization, participatory_space: component.participatory_space)
  end
  let(:component) do
    create(:component, :published)
  end
  let(:resource) do
    create(:dummy_resource, component:, published_at:)
  end
  let(:published_at) { Time.current }

  describe "user" do
    subject { described_class.new(model) }

    let(:author) { create(:user, :confirmed, organization: component.organization) }

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

    context "when there is no resource" do
      before do
        resource.delete
      end

      it { is_expected.not_to be_renderable }
    end

    context "when there is no participatory space" do
      before do
        component.participatory_space.delete
      end

      it { is_expected.not_to be_renderable }
    end
  end

  context "when a relationship is soft-deleted" do
    # A real case where this happened is when a comment entry points to a resource that belongs to a
    # participatory space that has been soft-deleted.
    before do
      allow(my_cell).to receive(:resource_link_path).and_raise(NoMethodError)
    end

    it "does not raise an error" do
      expect { subject }.not_to raise_error
    end
  end

  describe "#cache_hash" do
    subject { described_class.new(model, context: { controller:, show_author: }) }

    let(:controller) { double }
    let(:show_author) { false }

    before do
      allow(controller).to receive(:current_user).and_return(nil)
    end

    context "when the author is hidden" do
      context "and the user is updated" do
        let!(:original_hash) { subject.send(:cache_hash) }

        before do
          # rubocop:disable Rails/SkipsModelValidations
          resource.author.touch
          # rubocop:enable Rails/SkipsModelValidations

          subject.user.reload
        end

        it "does not change the cache hash" do
          expect(subject.send(:cache_hash)).to eq(original_hash)
        end
      end
    end
  end

  describe "#created_at" do
    subject { described_class.new(model) }

    let(:creating_date) { Time.zone.parse("2026-01-15 10:00:00") }
    let(:model) do
      create(:action_log, action: "publish", visibility: "all", resource:, organization: component.organization, participatory_space: component.participatory_space, created_at: creating_date)
    end

    context "when created_at is between zero and 59 seconds" do
      it "returns the correct datetime for client-side rendering and time ago text" do
        travel_to(creating_date) do
          expect(subject.created_at).to eq(creating_date)
        end

        travel_to(creating_date + 10.seconds) do
          expect(subject.created_at).to eq(creating_date)
        end

        travel_to(creating_date + 59.seconds) do
          expect(subject.created_at).to eq(creating_date)
        end
      end
    end

    context "when created_at is hours ago" do
      it "returns the correct datetime for client-side rendering and time ago text" do
        travel_to(creating_date + 2.hours) do
          expect(subject.created_at).to eq(creating_date)
        end

        travel_to(creating_date + 12.hours) do
          expect(subject.created_at).to eq(creating_date)
        end
      end
    end
  end

  describe "#notification_time" do
    it "renders the model date using LocalTime" do
      output = my_cell.send(:notification_time).to_s

      expect(output).to include("<time datetime")
      expect(output).to include('data-local="time-ago"')
      expect(output).to include(model.created_at.utc.iso8601)
    end
  end
end
