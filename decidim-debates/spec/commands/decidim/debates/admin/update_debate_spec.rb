# frozen_string_literal: true

require "spec_helper"

describe Decidim::Debates::Admin::UpdateDebate do
  subject { described_class.new(form, debate) }

  let(:debate) { create(:debate) }
  let(:organization) { debate.component.organization }
  let(:scope) { create(:scope, organization:) }
  let(:category) { create(:category, participatory_space: debate.component.participatory_space) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:attachment_params) { nil }
  let(:current_files) { [] }
  let(:uploaded_files) { [] }
  let(:form) do
    double(
      invalid?: invalid,
      current_user: user,
      title: { en: "title" },
      description: { en: "description" },
      information_updates: { en: "information_updates" },
      instructions: { en: "instructions" },
      start_time: 1.day.from_now,
      end_time: 1.day.from_now + 1.hour,
      scope:,
      category:,
      current_organization: organization,
      comments_enabled: true,
      attachment: attachment_params,
      add_documents: uploaded_files,
      documents: current_files
    )
  end
  let(:invalid) { false }

  context "when the form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when everything is ok" do
    it "updates the debate" do
      subject.call
      expect(translated(debate.title)).to eq "title"
      expect(translated(debate.description)).to eq "description"
      expect(translated(debate.information_updates)).to eq "information_updates"
      expect(translated(debate.instructions)).to eq "instructions"
    end

    it "sets the scope" do
      subject.call
      expect(debate.scope).to eq scope
    end

    it "sets the category" do
      subject.call
      expect(debate.category).to eq category
    end

    it "traces the action", versioning: true do
      expect(Decidim.traceability)
        .to receive(:update!)
        .with(debate, user, hash_including(:category, :title, :description, :information_updates, :instructions, :end_time, :start_time))
        .and_call_original

      expect { subject.call }.to change(Decidim::ActionLog, :count)
      action_log = Decidim::ActionLog.last
      expect(action_log.version).to be_present
      expect(action_log.version.event).to eq "update"
    end
  end

  context "when everything is ok with attachments" do
    let(:uploaded_files) do
      [
        { file: upload_test_file(Decidim::Dev.asset("city.jpeg"), content_type: "image/jpeg") },
        { file: upload_test_file(Decidim::Dev.asset("Exampledocument.pdf"), content_type: "application/pdf") }
      ]
    end

    it "updates the debate with attachments" do
      expect do
        subject.call
        debate.reload
      end.to change(debate.attachments, :count).by(2)

      debate_attachments = debate.attachments
      expect(debate_attachments.count).to eq(2)
    end
  end
end
