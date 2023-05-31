# frozen_string_literal: true

shared_examples_for "has comments availability attributes" do
  let(:comments_enabled) { nil }
  let(:comments_start_time) { nil }
  let(:comments_end_time) { nil }
  let(:updates) do
    { comments_enabled: }.merge(
      if subject.is_a?(Decidim::Debates::Debate)
        { start_time: comments_start_time, end_time: comments_end_time }
      else
        { comments_start_time:, comments_end_time: }
      end
    )
  end

  describe "#comments_allowed?" do
    before do
      subject.update(updates)
    end

    context "when all attributes are blank" do
      it { expect(subject.comments_allowed?).to be false }
    end

    context "when comments_enabled is false" do
      let(:comments_enabled) { false }

      context "and start time is in the past and end time in the future" do
        let(:comments_start_time) { 1.day.ago }
        let(:comments_end_time) { 2.days.from_now }

        it { expect(subject.comments_allowed?).to be false }
      end
    end

    context "when comments_enabled is true" do
      let(:comments_enabled) { true }

      context "and start and end time are blank" do
        it { expect(subject.comments_allowed?).to be true }
      end

      context "and start time is present and in the past" do
        let(:comments_start_time) { 1.day.ago }

        it { expect(subject.comments_allowed?).to be true }
      end

      context "and start time is present and in the future" do
        let(:comments_start_time) { 1.day.from_now }

        it { expect(subject.comments_allowed?).to be false }
      end

      context "and end time is present and in the future" do
        let(:comments_end_time) { 2.days.from_now }

        it { expect(subject.comments_allowed?).to be true }
      end

      context "and end time is present and in the past" do
        let(:comments_end_time) { 1.day.ago }

        it { expect(subject.comments_allowed?).to be false }
      end

      context "and start time is in the past and end time in the future" do
        let(:comments_start_time) { 1.day.ago }
        let(:comments_end_time) { 2.days.from_now }

        it { expect(subject.comments_allowed?).to be true }
      end
    end
  end
end
