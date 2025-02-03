# frozen_string_literal: true

require "spec_helper"

describe Decidim::Debates::UpdateDebate do
  subject { described_class.new(form, debate) }

  let(:organization) { create(:organization, available_locales: [:en, :ca, :es], default_locale: :en) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:current_component) { create(:component, participatory_space: participatory_process, manifest_name: "debates") }
  let(:user) { create(:user, organization:) }
  let(:author) { user }
  let!(:debate) { create(:debate, author:, component: current_component) }
  let(:current_files) { debate.attachments }
  let(:uploaded_files) { [] }
  let(:taxonomies) { create_list(:taxonomy, 2, :with_parent, organization:) }
  let(:form) do
    Decidim::Debates::DebateForm.from_params(
      title: "Title",
      description: "Description",
      documents: current_files,
      add_documents: uploaded_files,
      taxonomies:,
      id: debate.id
    ).with_context(
      current_organization: organization,
      current_participatory_space: current_component.participatory_space,
      current_component:,
      current_user: user
    )
  end

  describe "when the form is not valid" do
    before do
      allow(form).to receive(:invalid?).and_return(true)
    end

    it "broadcasts invalid" do
      expect { subject.call }.to broadcast(:invalid)
    end

    it "does not update the debate" do
      expect do
        subject.call
        debate.reload
      end.not_to change(debate, :title)
    end
  end

  describe "when the debate is not editable by the user" do
    let(:author) { create(:user, organization:) }

    it "broadcasts invalid" do
      expect { subject.call }.to broadcast(:invalid)
    end

    it "does not update the debate" do
      expect do
        subject.call
        debate.reload
      end.not_to change(debate, :title)
    end
  end

  describe "when everything is ok" do
    it "updates the debate" do
      expect do
        subject.call
        debate.reload
      end.to change(debate, :title)
    end

    it_behaves_like "fires an ActiveSupport::Notification event", "decidim.debates.update_debate:before" do
      let(:command) { subject }
    end
    it_behaves_like "fires an ActiveSupport::Notification event", "decidim.debates.update_debate:after" do
      let(:command) { subject }
    end

    it "sets the taxonomies" do
      subject.call
      expect(debate.reload.taxonomies).to match_array(taxonomies)
    end

    it "sets the title with i18n" do
      subject.call
      debate.reload
      expect(debate.title.except("machine_translations").values.uniq).to eq ["Title"]
    end

    it "sets the description with i18n" do
      subject.call
      debate.reload
      expect(debate.description.except("machine_translations").values.uniq).to eq ["Description"]
    end

    it "traces the action", versioning: true do
      expect(Decidim.traceability)
        .to receive(:update!)
        .with(
          Decidim::Debates::Debate,
          user,
          hash_including(:taxonomizations, :title, :description),
          visibility: "public-only"
        )
        .and_call_original

      expect { subject.call }.to change(Decidim::ActionLog, :count)
      action_log = Decidim::ActionLog.last
      expect(action_log.version).to be_present
      expect(action_log.version.event).to eq "update"
    end
  end

  describe "when debate with attachments" do
    let(:current_component) { create(:component, participatory_space: participatory_process, manifest_name: "debates", settings: { "attachments_allowed" => true }) }
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
        pp form.errors
      end.to change(debate.attachments, :count).by(2)

      debate_attachments = debate.attachments
      expect(debate_attachments.count).to eq(2)
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
  end

  describe "when debate already has attachments" do
    let!(:attachment1) { create(:attachment, attached_to: debate, weight: 1, file: file1) }
    let!(:attachment2) { create(:attachment, attached_to: debate, weight: 2, file: file2) }
    let(:file1) { upload_test_file(Decidim::Dev.asset("city.jpeg"), content_type: "image/jpeg") }
    let(:file2) { upload_test_file(Decidim::Dev.asset("Exampledocument.pdf"), content_type: "application/pdf") }
    let(:file3) { upload_test_file(Decidim::Dev.asset("city2.jpeg"), content_type: "image/jpeg") }

    let(:uploaded_files) do
      [
        { file: file3 }
      ]
    end

    it "adds new attachments and calculates correct weights" do
      expect(debate.attachments.count).to eq(2)
      expect(debate.attachments.map(&:weight)).to eq([1, 2])

      expect do
        subject.call
        debate.reload
      end.to change(debate.attachments, :count).by(1)

      expect(debate.attachments.count).to eq(3)
      expect(debate.attachments.map(&:weight)).to eq([1, 2, 3])
    end
  end

  describe "when ActiveRecord::RecordInvalid is raised" do
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

  describe "when Decidim::Commands::HookError is raised" do
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
