# frozen_string_literal: true

require "spec_helper"

module Decidim::Demographics
  describe DeleteDemographicData do
    subject { described_class.new(questionnaire, user) }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, :confirmed, organization:) }
    let(:questionnaire) { create(:questionnaire, questionnaire_for: create(:demographic, organization:)) }
    let(:question) { create(:questionnaire_question, questionnaire:) }

    before do
      create(:response, questionnaire:, question:, user:)
      create(:response, questionnaire:, question:)
    end

    it "broadcasts ok" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "destroys the submission of the user only" do
      expect { subject.call }.to change(Decidim::Forms::Submission, :count).by(-1)
      expect(questionnaire.submissions.where(user:)).to be_empty
    end
  end
end
