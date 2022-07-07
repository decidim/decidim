# frozen_string_literal: true

require "spec_helper"

describe "decidim_meetings:clean_registration_forms", type: :task do
  let(:months) { 3 }
  let(:threshold) { Time.current - months.months }

  it "preloads the Rails environment" do
    expect(task.prerequisites).to include "environment"
  end

  it "runs gracefully" do
    expect { task.execute }.not_to raise_error
  end

  context "when a meeting has finished before the given threshold" do
    let!(:meeting) { create(:meeting, end_time: 4.months.ago) }
    let(:questionnaire) { meeting.questionnaire }

    it "removes related questionnaires and answers but not the meeting itself" do
      expect(meeting.end_time).to be <= threshold
      task.execute(months: months)

      expect { questionnaire.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect(meeting.reload).to be_present
    end
  end

  context "when a meeting has finished after the given threshold" do
    let!(:meeting) { create(:meeting, end_time: 2.months.ago) }
    let(:questionnaire) { meeting.questionnaire }

    it "does not remove anything" do
      expect(questionnaire.id).to eq(meeting.questionnaire.id)

      expect(meeting.end_time).to be > threshold
      task.execute(months: months)

      expect(questionnaire.reload).to be_present
      expect(meeting.reload).to be_present
    end
  end
end
