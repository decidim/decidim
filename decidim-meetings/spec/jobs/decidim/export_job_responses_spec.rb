# frozen_string_literal: true

require "spec_helper"

describe Decidim::ExportJob do
  let(:meeting) { create(:meeting) }
  let(:component) { meeting.component }
  let(:user) { create(:user, :admin, :confirmed, organization: component.organization) }
  let(:poll) { create(:poll, meeting:) }
  let(:questionnaire) { create(:meetings_poll_questionnaire, questionnaire_for: poll) }

  context "when exporting the responses of a questionnaire without responses" do
    %w(CSV JSON Excel FormPDF).each do |format|
      it "sends the export email in #{format} format" do
        expect do
          described_class.perform_now(user, component, "responses", format, questionnaire.id)
        end.to have_enqueued_mail(Decidim::ExportMailer, :export)
      end
    end
  end
end
