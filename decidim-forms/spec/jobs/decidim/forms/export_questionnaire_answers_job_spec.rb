# frozen_string_literal: true

require "spec_helper"

describe Decidim::Forms::ExportQuestionnaireAnswersJob do
  subject { described_class }

  let!(:user) { create(:user, :admin) }
  let!(:title) { "The answers" }
  let!(:questionnaire) { create(:questionnaire) }
  let!(:questions) { create_list(:questionnaire_question, 3, questionnaire:) }
  let!(:answers) { questions.map { |q| create(:answer, question: q, questionnaire:) } }
  let!(:collection) { [answers] }

  describe "queue" do
    it "is queued to events" do
      expect(subject.queue_name).to eq "exports"
    end
  end

  describe "when everything is OK" do
    let(:mailer) { double :mailer }

    it "sends an email" do
      allow(Decidim::ExportMailer)
        .to receive(:export)
        .and_return(mailer)
      expect(mailer)
        .to receive(:deliver_now)

      subject.perform_now(user, title, collection)
    end
  end

  describe "when no answers" do
    it "doesn't send the email" do
      collection = []

      expect(Decidim::ExportMailer)
        .not_to receive(:export)

      subject.perform_now(user, title, collection)
    end
  end

  describe "when no user" do
    it "doesn't send the email" do
      user = nil

      expect(Decidim::ExportMailer)
        .not_to receive(:export)

      subject.perform_now(user, title, collection)
    end
  end

  describe "when user has no email" do
    it "doesn't send the email" do
      user.update(email: "")

      expect(Decidim::ExportMailer)
        .not_to receive(:export)

      subject.perform_now(user, title, collection)
    end
  end
end
