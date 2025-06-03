# frozen_string_literal: true

require "spec_helper"

describe "Meetings component" do # rubocop:disable RSpec/DescribeClass
  let!(:component) { create(:meeting_component) }
  let(:organization) { component.organization }
  let!(:current_user) { create(:user, :admin, organization:) }

  describe "statistics" do
    subject { current_stat[1][:data] }

    let(:raw_stats) do
      Decidim.component_manifests.map do |component_manifest|
        component_manifest.stats.filter(name: stats_name).with_context(component).flat_map { |name, data| [component_manifest.name, name, data] }
      end
    end

    let(:stats) do
      raw_stats.select { |stat| stat[0] == :meetings }
    end

    let!(:meeting) { create(:meeting, :published) }
    let(:component) { meeting.component }
    let!(:another_meeting) { create(:meeting, :published, component:) }
    let!(:hidden_meeting) { create(:meeting, :published, component:) }
    let!(:moderation) { create(:moderation, reportable: hidden_meeting, hidden_at: 1.day.ago) }

    let(:current_stat) { stats.find { |stat| stat[1][:name] == stats_name } }

    describe "meetings_count" do
      let(:stats_name) { :meetings_count }

      it "only counts published and not hidden meetings" do
        expect(Decidim::Meetings::Meeting.where(component:).count).to eq 3
        expect(subject).to eq 2
      end

      context "when having withdrawn meeting" do
        let!(:withdrawn_meeting) { create(:meeting, :withdrawn, component:) }

        it "will exclude the withdrawn one" do
          expect(Decidim::Meetings::Meeting.where(component:).count).to eq 4
          expect(subject).to eq 2
        end
      end
    end

    describe "likes_count" do
      let(:stats_name) { :followers_count }

      before do
        2.times do
          create(:follow, followable: meeting, user: build(:user, organization:))
        end
        3.times do
          create(:follow, followable: hidden_meeting, user: build(:user, organization:))
        end
      end

      it "counts the followers from visible meetings" do
        expect(Decidim::Follow.count).to eq 5
        expect(subject).to eq 2
      end
    end

    describe "comments_count" do
      let(:stats_name) { :comments_count }

      before do
        create_list(:comment, 3, commentable: meeting)
        create_list(:comment, 5, commentable: hidden_meeting)
      end

      it "counts the comments from visible meetings" do
        expect(Decidim::Comments::Comment.count).to eq 8
        expect(subject).to eq 3
      end
    end

    describe "attendees_count" do
      let(:stats_name) { :attendees_count }
      let!(:a_closed_meeting) { create(:meeting, :published, :closed, attendees_count: 5, component:) }
      let!(:another_closed_meeting) { create(:meeting, :published, :closed, attendees_count: 15, component:) }
      let!(:hidden_meeting) { create(:meeting, :published, :closed, attendees_count: 25, component:) }
      let!(:closing_hidden) { create(:meeting, :published, :closed, closing_visible: false, attendees_count: 25, component:) }

      it "counts the attendees count from visible meetings" do
        expect(Decidim::Meetings::Meeting.sum(:attendees_count)).to eq 70
        expect(subject).to eq 20
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

    let!(:first_meeting) { create(:meeting, :published) }
    let(:component) { first_meeting.component }
    let!(:second_meeting) { create(:meeting, :published, component:) }
    let!(:unpublished_meeting) { create(:meeting, component:) }
    let(:participatory_process) { component.participatory_space }
    let(:organization) { participatory_process.organization }

    context "when the user is an admin" do
      let!(:user) { create(:user, admin: true, organization:) }

      it "exports all meetings from the component" do
        expect(subject).to contain_exactly(first_meeting, second_meeting, unpublished_meeting)
      end
    end
  end
end
