# frozen_string_literal: true

require "spec_helper"

shared_examples_for "reportable" do
  context "when reportable" do
    let(:user) { create(:user, organization: subject.organization) }
    let(:participatory_space) { subject.component.participatory_space }
    let(:moderation) { create(:moderation, reportable: subject, participatory_space:, report_count: 1) }
    let!(:report) { create(:report, moderation:, user:) }

    describe "#reported_by?" do
      context "when the resource has not been reported by the given user" do
        let!(:report) { nil }

        it { expect(subject).not_to be_reported_by(user) }
      end

      context "when the resource has been reported" do
        it { expect(subject).to be_reported_by(user) }
      end
    end

    describe "#hidden?" do
      context "when the resource has not been hidden" do
        it { expect(subject).not_to be_hidden }
      end

      context "when the resource has been hidden" do
        let(:moderation) { create(:moderation, reportable: subject, participatory_space:, report_count: 1, hidden_at: Time.current) }

        before do
          subject.reload
        end

        it { expect(subject).to be_hidden }
      end
    end

    describe "#reported?" do
      context "when the report count is equal to 0" do
        let(:moderation) { create(:moderation, reportable: subject, participatory_space:, report_count: 0) }
        let!(:report) { nil }

        it { expect(subject).not_to be_reported }
      end

      context "when the report count is greater than 0" do
        before do
          subject.reload
        end

        it { expect(subject).to be_reported }
      end
    end
  end
end
