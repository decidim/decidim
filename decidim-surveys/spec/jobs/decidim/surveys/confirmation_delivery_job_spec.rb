# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Surveys
    describe ConfirmationDeliveryJob do
      subject { described_class }

      let(:survey) { create(:survey) }
      let(:component) { survey.component }
      let(:user) { create(:user, organization: component.organization) }
      let(:questionnaire) { survey.questionnaire }
      let!(:questions) { create_list(:questionnaire_question, 3, questionnaire:) }
      let!(:answers) { questions.map { |q| create(:answer, question: q, questionnaire:) } }
      let!(:collection) { [answers] }

      describe "queue" do
        it "is queued to events" do
          expect(subject.queue_name).to eq "default"
        end
      end

      context "when there is answers in questionnaire" do
        let(:mailer) { double :mailer }

        it "notifies the confirmation of answer" do
          allow(Decidim::Surveys::ConfirmationDeliveryJob)
            .to receive(:default)
            .and_return(mailer)
          expect(mailer)
            .to receive(:deliver_now)

          subject.perform_now(user, questionnaire, component, collection)
        end
      end
    end
  end
end
