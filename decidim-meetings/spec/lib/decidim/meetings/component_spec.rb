# frozen_string_literal: true

require "spec_helper"

describe "Meetings component" do # rubocop:disable RSpec/DescribeClass
  let!(:component) { create(:meeting_component) }
  let(:organization) { component.organization }
  let!(:current_user) { create(:user, :admin, organization: organization) }

  describe "on destroy" do
    context "when there are no meetings for the component" do
      it "destroys the component" do
        expect do
          Decidim::Admin::DestroyComponent.call(component, current_user)
        end.to change(Decidim::Component, :count).by(-1)

        expect(component).to be_destroyed
      end
    end

    context "when there are meetings for the component" do
      before do
        create(:meeting, component: component)
      end

      it "raises an error" do
        expect do
          Decidim::Admin::DestroyComponent.call(component, current_user)
        end.to broadcast(:invalid)

        expect(component).not_to be_destroyed
      end
    end
  end

  describe "statistics" do
    subject { current_stat[2] }

    let(:raw_stats) do
      Decidim.component_manifests.map do |component_manifest|
        component_manifest.stats.filter(name: stats_name).with_context(component).flat_map { |name, data| [component_manifest.name, name, data] }
      end
    end

    let(:stats) do
      raw_stats.select { |stat| stat[0] == :meetings }
    end

    let!(:meeting) { create :meeting, :published }
    let(:component) { meeting.component }
    let!(:another_meeting) { create :meeting, :published, component: component }
    let!(:hidden_meeting) { create :meeting, :published, component: component }
    let!(:moderation) { create :moderation, reportable: hidden_meeting, hidden_at: 1.day.ago }

    let(:current_stat) { stats.find { |stat| stat[1] == stats_name } }

    describe "meetings_count" do
      let(:stats_name) { :meetings_count }

      it "only counts published and not hidden meetings" do
        expect(Decidim::Meetings::Meeting.where(component: component).count).to eq 3
        expect(subject).to eq 2
      end

      context "when having withdrawn meeting" do
        let!(:withdrawn_meeting) { create :meeting, :withdrawn, component: component }

        it "will exclude the withdrawn one" do
          expect(Decidim::Meetings::Meeting.where(component: component).count).to eq 4
          expect(subject).to eq 2
        end
      end
    end

    describe "endorsements_count" do
      let(:stats_name) { :followers_count }

      before do
        # rubocop:disable RSpec/FactoryBot/CreateList
        2.times do
          create(:follow, followable: meeting, user: build(:user, organization: organization))
        end
        3.times do
          create(:follow, followable: hidden_meeting, user: build(:user, organization: organization))
        end
        # rubocop:enable RSpec/FactoryBot/CreateList
      end

      it "counts the followers from visible meetings" do
        expect(Decidim::Follow.count).to eq 5
        expect(subject).to eq 2
      end
    end

    describe "comments_count" do
      let(:stats_name) { :comments_count }

      before do
        create_list :comment, 3, commentable: meeting
        create_list :comment, 5, commentable: hidden_meeting
      end

      it "counts the comments from visible proposals" do
        expect(Decidim::Comments::Comment.count).to eq 8
        expect(subject).to eq 3
      end
    end
  end

  describe "meeting exporter" do
    subject do
      component
        .manifest
        .export_manifests
        .find { |manifest| manifest.name == :meetings }
        .collection
        .call(component, user)
    end

    let!(:first_meeting) { create :meeting, :published }
    let(:component) { first_meeting.component }
    let!(:second_meeting) { create :meeting, :published, component: component }
    let!(:unpublished_meeting) { create :meeting, component: component }
    let(:participatory_process) { component.participatory_space }
    let(:organization) { participatory_process.organization }

    context "when the user is an admin" do
      let!(:user) { create :user, admin: true, organization: organization }

      it "exports all meetings from the component" do
        expect(subject).to match_array([first_meeting, second_meeting, unpublished_meeting])
      end
    end
  end
end
