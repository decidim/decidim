# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe ResponseChoice do
      subject { response_choice }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, organization:) }
      let(:meeting) { create(:meeting) }
      let(:poll) { create(:poll, meeting:) }
      let(:questionnaire) { create(:meetings_poll_questionnaire, questionnaire_for: poll) }
      let(:question_type) { "single_option" }
      let(:question) { create(:meetings_poll_question, questionnaire:, question_type:) }
      let(:response_options) { create_list(:meetings_poll_response_option, 3, question:) }
      let(:response_option) { response_options.first }
      let(:response) { create(:meetings_poll_response, question:, questionnaire:) }
      let(:response_choice) { build(:meetings_poll_response_choice, response:, response_option:) }

      it { is_expected.to be_valid }

      it "has an association of response" do
        expect(subject.response).to eq(response)
      end

      it "has an association of response_option" do
        expect(subject.response_option).to eq(response_option)
      end
    end
  end
end
