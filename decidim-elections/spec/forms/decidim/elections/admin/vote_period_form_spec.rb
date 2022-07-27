# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Admin::VotePeriodForm do
  subject { described_class.from_params(attributes).with_context(context) }

  let(:context) do
    {
      current_organization: component.organization,
      current_component: component,
      election:,
      current_step:
    }
  end
  let(:component) { election.component }
  let(:current_step) { election.bb_status }
  let(:attributes) { {} }

  describe "for an election ready to start" do
    let(:election) { create :election, :key_ceremony_ended, start_time: }
    let(:start_time) { 1.hour.from_now }
    let(:formatted_start_time) { I18n.l(start_time, format: :long) }

    it { is_expected.to be_valid }

    it "shows a message" do
      expect(subject.messages).to eq({
                                       time_before: "The election will start soon. You can start the voting period manually, or it will be started automatically before the starting time, at #{formatted_start_time}."
                                     })
    end

    context "when the election is not going to start soon" do
      let(:start_time) { 10.days.from_now }

      it { is_expected.to be_invalid }

      it "shows an error message" do
        subject.valid?
        expect(subject.errors.messages).to eq({
                                                time_before: ["The election is ready to start. You have to wait until 6 hours before the starting time (#{formatted_start_time}) to start the voting period."]
                                              })
      end
    end
  end

  describe "for an election recently finished" do
    let(:election) { create :election, :vote, end_time: }
    let(:end_time) { 1.minute.ago }
    let(:formatted_end_time) { I18n.l(end_time, format: :long) }

    it { is_expected.to be_valid }

    it "shows a message" do
      expect(subject.messages).to eq({
                                       time_after: "The election has ended. You can end the voting period manually, or it will be ended automatically in a few minutes."
                                     })
    end

    context "when the election didn't finish yet" do
      let(:end_time) { 1.day.from_now }

      it { is_expected.to be_invalid }

      it "shows an error message" do
        subject.valid?
        expect(subject.errors.messages).to eq({
                                                time_after: ["The election is still ongoing. You have to wait until the ending time (#{formatted_end_time}) to end the voting period."]
                                              })
      end
    end
  end
end
