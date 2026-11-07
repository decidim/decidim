# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    describe Submission do
      subject { submission }

      let(:questionnaire) { create(:questionnaire) }
      let(:submission) { create(:submission, questionnaire:) }

      it { is_expected.to be_valid }

      it "rejects a duplicate session token in the same questionnaire" do
        expect { create(:submission, questionnaire:, session_token: submission.session_token) }.to raise_error(ActiveRecord::RecordNotUnique)
      end

      it "allows the same session token in another questionnaire" do
        other = create(:submission, session_token: submission.session_token)
        expect(other).to be_persisted
      end

      it "destroys its responses" do
        response = create(:response, questionnaire:, submission:)
        submission.destroy!
        expect(Response.where(id: response.id)).not_to exist
      end

      context "when anonymous" do
        let(:submission) { create(:submission, questionnaire:, user: nil) }

        it { is_expected.to be_valid }
      end
    end
  end
end
