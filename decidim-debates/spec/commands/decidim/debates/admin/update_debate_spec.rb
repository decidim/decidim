# frozen_string_literal: true

require "spec_helper"

describe Decidim::Debates::Admin::UpdateDebate do
  subject { described_class.new(form, debate) }

  let(:debate) { create(:debate) }
  let(:organization) { debate.component.organization }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:attachment_params) { nil }
  let(:current_files) { [] }
  let(:uploaded_files) { [] }
  let(:taxonomizations) do
    2.times.map { build(:taxonomization, taxonomy: create(:taxonomy, :with_parent, organization:), taxonomizable: nil) }
  end
  let(:comments_layout) { "two_columns" }
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
      taxonomizations:,
      current_organization: organization,
      comments_enabled: true,
      comments_layout:,
      attachment: attachment_params,
      add_documents: uploaded_files,
      documents: current_files,
      errors: ActiveModel::Errors.new(self)
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
      expect(debate.comments_layout).to eq "two_columns"
    end

    it "sets the taxonomies" do
      subject.call
      expect(debate.reload.taxonomies).to match_array(taxonomizations.map(&:taxonomy))
    end

    it "traces the action", versioning: true do
      expect(Decidim.traceability)
        .to receive(:update!)
        .with(debate, user, hash_including(:taxonomizations, :title, :description, :information_updates, :instructions, :end_time, :start_time))
        .and_call_original

      expect { subject.call }.to change(Decidim::ActionLog, :count)
      action_log = Decidim::ActionLog.last
      expect(action_log.version).to be_present
      expect(action_log.version.event).to eq "update"
    end
  end

  describe "when debate with attachments" do
    let!(:attachment1) { create(:attachment, attached_to: debate, weight: 1, file: file1) }
    let!(:attachment2) { create(:attachment, attached_to: debate, weight: 2, file: file2) }
    let(:file1) { upload_test_file(Decidim::Dev.asset("city.jpeg"), content_type: "image/jpeg") }
    let(:file2) { upload_test_file(Decidim::Dev.asset("Exampledocument.pdf"), content_type: "application/pdf") }
    let(:file3) { upload_test_file(Decidim::Dev.asset("city2.jpeg"), content_type: "image/jpeg") }
    let(:current_files) { [attachment1, attachment2] }
    let(:uploaded_files) { [{ file: file3 }] }

    it "updates the debate with attachments" do
      expect(debate.attachments.count).to eq(2)
      expect(debate.attachments.map(&:weight)).to eq([1, 2])

      expect do
        subject.call
        debate.reload
      end.to change(debate.attachments, :count).by(1)

      expect(debate.attachments.count).to eq(3)
      expect(debate.attachments.map(&:weight)).to eq([1, 2, 3])
    end

    context "when attachments are invalid" do
      let(:uploaded_files) do
        [
          { file: upload_test_file(Decidim::Dev.test_file("participatory_text.odt", "application/vnd.oasis.opendocument.text")) }
        ]
      end

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
        expect { subject.call }.not_to change(Decidim::Debates::Debate, :count)
        expect { subject.call }.not_to change(Decidim::Attachment, :count)
      end
    end

    context "when ActiveRecord::RecordInvalid is raised" do
      before do
        allow(debate).to receive(:update!).and_raise(ActiveRecord::RecordInvalid.new(debate))
      end

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end

      it "does not update the debate" do
        expect(debate.title.except("machine_translations").values.uniq).not_to eq ["title"]
      end
    end

    context "when Decidim::Commands::HookError is raised" do
      subject { command_instance }

      let(:command_instance) { described_class.new(form, debate) }

      before do
        allow(command_instance).to receive(:perform!).and_raise(Decidim::Commands::HookError)
      end

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end
  end
end
