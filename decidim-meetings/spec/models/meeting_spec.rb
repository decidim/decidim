# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe Meeting do
    subject { meeting }

    let(:address) { Faker::Lorem.sentence(word_count: 3) }
    let(:meeting) { build :meeting, address: address }

    it { is_expected.to be_valid }
    it { is_expected.to be_versioned }

    include_examples "has component"
    include_examples "has scope"
    include_examples "has category"
    include_examples "has reference"
    include_examples "resourceable"
    include_examples "reportable"

    it "has an association with one agenda" do
      subject.agenda = build_stubbed(:agenda)
      expect(subject.agenda).to be_present
    end

    it "has an association of invites" do
      subject.invites << build_stubbed(:invite)
      subject.invites << build_stubbed(:invite)
      expect(subject.invites.size).to eq(2)
    end

    it "has an association with one questionnaire" do
      subject.questionnaire = build_stubbed(:questionnaire)
      expect(subject.questionnaire).to be_present
    end

    context "without a title" do
      let(:meeting) { build :meeting, title: nil }

      it { is_expected.not_to be_valid }
    end

    context "when geocoding is enabled" do
      let(:address) { "Carrer del Pare Llaurador, 113" }
      let(:latitude) { 40.1234 }
      let(:longitude) { 2.1234 }

      before do
        stub_geocoding(address, [latitude, longitude])
      end

      it "geocodes address and find latitude and longitude" do
        subject.geocode
        expect(subject.latitude).to eq(latitude)
        expect(subject.longitude).to eq(longitude)
      end
    end

    describe "#users_to_notify_on_comment_created" do
      let!(:follows) { create_list(:follow, 3, followable: subject) }

      it "returns the followers" do
        expect(subject.users_to_notify_on_comment_created).to match_array(follows.map(&:user))
      end
    end

    describe "#can_be_joined_by?" do
      subject { meeting.can_be_joined_by?(user) }

      let(:user) { build :user, organization: meeting.component.organization }

      context "when registrations are disabled" do
        let(:meeting) { build :meeting, registrations_enabled: false }

        it { is_expected.to eq false }
      end

      context "when meeting is closed" do
        let(:meeting) { build :meeting, :closed }

        it { is_expected.to eq false }
      end

      context "when the user cannot participate to the meeting" do
        let(:meeting) { build :meeting, :closed }

        before do
          allow(meeting).to receive(:can_participate?).and_return(false)
        end

        it { is_expected.to eq false }
      end

      context "when everything is OK" do
        let(:meeting) { build :meeting, registrations_enabled: true }

        it { is_expected.to eq true }
      end
    end

    describe "#can_register_invitation?" do
      subject { meeting.can_register_invitation?(user) }

      let(:user) { build :user, organization: meeting.component.organization }

      context "when registrations are disabled" do
        let(:meeting) { build :meeting, registrations_enabled: false }

        it { is_expected.to eq false }
      end

      context "when meeting is closed" do
        let(:meeting) { build :meeting, :closed }

        it { is_expected.to eq false }
      end

      context "when the user cannot participate to the meeting" do
        let(:meeting) { build :meeting, :closed }

        before do
          allow(meeting).to receive(:can_register_invitation?).and_return(false)
        end

        it { is_expected.to eq false }
      end

      context "when everything is OK" do
        let(:meeting) { build :meeting, registrations_enabled: true }

        it { is_expected.to eq true }
      end

      context "when no user on register process" do
        let(:meeting) { build :meeting, registrations_enabled: true, private_meeting: true, transparent: false }
        let(:user) { nil }

        it { is_expected.to eq false }
      end

      context "when user has invitation to register" do
        let(:meeting) { create :meeting, registrations_enabled: true, private_meeting: true, transparent: false }
        let(:invite) { create(:invite, accepted_at: Time.current, rejected_at: nil, user: user, meeting: meeting) }

        it "allows the user to join the meeting" do
          meeting.invites << invite
          expect(subject).to eq true
        end
      end

      context "when user has no invitation to register" do
        let(:meeting) { build :meeting, registrations_enabled: true, private_meeting: true, transparent: false }

        it { is_expected.to eq false }
      end
    end

    describe "#meeting_duration" do
      let(:start_time) { 1.day.from_now }
      let!(:meeting) { build(:meeting, start_time: start_time, end_time: start_time.advance(hours: 2)) }

      it "return the duration of the meeting in minutes" do
        expect(subject.meeting_duration).to eq(120)
      end
    end

    describe "#resource_visible?" do
      context "when Meeting is private non transparent" do
        before { subject.update(private_meeting: true, transparent: false) }

        it { is_expected.not_to be_resource_visible }
      end

      context "when Meeting is private but transparent" do
        before { subject.update(private_meeting: true, transparent: true) }

        it { is_expected.to be_resource_visible }
      end

      context "when Meeting is moderated" do
        let!(:moderation) { create(:moderation, :hidden, reportable: meeting) }

        before { subject.reload }

        it { is_expected.not_to be_resource_visible }
      end
    end

    describe "#salt" do
      it "salt is empty before saving" do
        expect(subject.salt).not_to be_present
      end

      context "when is created" do
        before do
          meeting.save!
        end

        it "has a salt defined" do
          expect(subject.salt).to be_present
        end
      end

      context "when is updated" do
        let!(:meeting) { create :meeting }

        context "and salt is empty" do
          before do
            meeting.start_time = 1.day.from_now
            meeting.salt = ""
            meeting.save!
          end

          it "salt remains empty" do
            expect(subject.salt).not_to be_present
          end
        end

        context "and salt is present" do
          before do
            meeting.start_time = 1.day.from_now
            meeting.save!
          end

          it "salt remains the same" do
            expect(subject.salt).to be_present
          end
        end
      end
    end

    describe "pad_is_visible?" do
      let(:pad) { instance_double(EtherpadLite::Pad, id: "pad-id", read_only_id: "read-only-id") }

      before do
        allow(meeting).to receive(:pad).and_return(pad)
      end

      context "when there's no pad" do
        let(:pad) { nil }

        it "returns false" do
          expect(subject).not_to be_pad_is_visible
        end
      end

      context "when the meeting starts more than 24 hours from now" do
        before do
          meeting.start_time = 2.days.from_now
        end

        it "returns false" do
          expect(subject).not_to be_pad_is_visible
        end
      end

      context "when the meeting starts less than 24 hours from now" do
        before do
          meeting.start_time = 24.hours.from_now
        end

        it "returns true" do
          expect(subject).to be_pad_is_visible
        end
      end

      context "when the meeting has started" do
        before do
          meeting.start_time = 1.hour.ago
        end

        it "returns true" do
          expect(subject).to be_pad_is_visible
        end
      end
    end

    describe "pad_is_writable?" do
      let(:pad) { instance_double(EtherpadLite::Pad, id: "pad-id", read_only_id: "read-only-id") }

      before do
        allow(meeting).to receive(:pad).and_return(pad)
        subject.start_time = Time.current
        expect(subject).to be_pad_is_visible
      end

      context "when the meeting ended more than 72 hours ago" do
        before do
          meeting.end_time = 4.days.ago
        end

        it "returns false" do
          expect(subject).not_to be_pad_is_writable
        end
      end

      context "when the meeting ended less than 72 hours ago" do
        before do
          meeting.end_time = 2.days.ago
        end

        it "returns true" do
          expect(subject).to be_pad_is_writable
        end
      end

      context "when the pad is not visible" do
        before do
          expect(meeting).to receive(:pad_is_visible?).and_return(false)
        end

        it "returns false" do
          expect(subject).not_to be_pad_is_writable
        end
      end
    end

    describe "#past?" do
      context "when past meeting" do
        let(:meeting) { build :meeting, :past }

        it "returns true" do
          expect(subject.past?).to be true
        end
      end

      context "when future meeting" do
        it "returns false" do
          expect(subject.past?).to be false
        end
      end
    end

    describe "#has_contributions?" do
      context "when the meeting has contributions" do
        let(:meeting) { build :meeting, contributions_count: 10 }

        it "returns true" do
          expect(subject.has_contributions?).to be true
        end
      end

      context "when the meeting does not have contributions" do
        let(:meeting) { build :meeting }

        it "returns false" do
          expect(subject.has_contributions?).to be false
        end
      end
    end

    describe "#has_attendees?" do
      context "when the meeting has attendees" do
        let(:meeting) { build :meeting, attendees_count: 10 }

        it "returns true" do
          expect(subject.has_attendees?).to be true
        end
      end

      context "when the meeting does not have attendees" do
        let(:meeting) { build :meeting }

        it "returns false" do
          expect(subject.has_attendees?).to be false
        end
      end
    end
  end
end
