# frozen_string_literal: true

require "spec_helper"

describe Decidim::Debates::CreateDebate do
  subject { described_class.new(form) }

  let(:organization) { create(:organization, available_locales: [:en, :ca, :es], default_locale: :en) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:current_component) { create(:component, participatory_space: participatory_process, manifest_name: "debates") }
  let(:user) { create(:user, organization:) }
  let(:attachments) { [] }
  let(:taxonomizations) do
    2.times.map { build(:taxonomization, taxonomy: create(:taxonomy, :with_parent, organization:), taxonomizable: nil) }
  end
  let(:form) do
    double(
      invalid?: invalid,
      title: "title",
      description: "description",
      taxonomizations:,
      current_user: user,
      current_component:,
      current_organization: organization,
      add_documents: attachments,
      documents: [],
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
    let(:debate) { Decidim::Debates::Debate.last }

    it "creates the debate" do
      expect { subject.call }.to change(Decidim::Debates::Debate, :count).by(1)
    end

    it_behaves_like "fires an ActiveSupport::Notification event", "decidim.debates.create_debate:before" do
      let(:command) { subject }
    end
    it_behaves_like "fires an ActiveSupport::Notification event", "decidim.debates.create_debate:after" do
      let(:command) { subject }
    end

    it "sets the taxonomies" do
      subject.call
      expect(debate.taxonomizations).to match_array(taxonomizations)
    end

    context "when no taxonomizations are set" do
      let(:taxonomizations) { [] }

      it "taxonomizations are empty" do
        subject.call
        expect(debate.taxonomizations).to be_empty
      end
    end

    it "sets the component" do
      subject.call
      expect(debate.component).to eq current_component
    end

    it "sets the author" do
      subject.call
      expect(debate.author).to eq user
    end

    it "sets the title with i18n" do
      subject.call
      expect(debate.title.values.uniq).to eq ["title"]
    end

    it "sets the description with i18n" do
      subject.call
      expect(debate.description.values.uniq).to eq ["description"]
    end

    it "traces the action", versioning: true do
      expect(Decidim.traceability)
        .to receive(:create!)
        .with(
          Decidim::Debates::Debate,
          user,
          hash_including(:taxonomizations, :title, :description, :component, :author),
          visibility: "public-only"
        )
        .and_call_original

      expect { subject.call }.to change(Decidim::ActionLog, :count)
      action_log = Decidim::ActionLog.last
      expect(action_log.version).to be_present
      expect(action_log.version.event).to eq "create"
    end

    it "makes the author follow the debate" do
      subject.call
      expect(Decidim::Follow.where(user:, followable: debate).count).to eq(1)
    end
  end

  context "when everything is ok with attachments" do
    let(:attachments) do
      [
        { file: upload_test_file(Decidim::Dev.test_file("city.jpeg", "image/jpeg")) },
        { file: upload_test_file(Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf")) }
      ]
    end

    let(:debate) { Decidim::Debates::Debate.last }

    it "creates the debate with attachments" do
      expect { subject.call }.to change(Decidim::Debates::Debate, :count).by(1) & change(Decidim::Attachment, :count).by(2)
      expect(debate.attachments.map(&:weight)).to eq([1, 2])

      debate_attachments = debate.attachments
      expect(debate_attachments.count).to eq(2)
      expect(debate_attachments.map(&:file).map(&:filename).map(&:to_s)).to contain_exactly("city.jpeg", "Exampledocument.pdf")
    end
  end

  context "when attachments are invalid" do
    let(:attachments) do
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

  describe "when ActiveRecord::RecordInvalid is raised" do
    before do
      allow(Decidim::Debates::Debate).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(Decidim::Debates::Debate.new))
    end

    it "broadcasts invalid" do
      expect { subject.call }.to broadcast(:invalid)
    end

    it "does not create a debate" do
      expect do
        subject.call
      end.not_to change(Decidim::Debates::Debate, :count)
    end
  end

  describe "when Decidim::Commands::HookError is raised" do
    subject { command_instance }

    let(:command_instance) { described_class.new(form) }

    before do
      allow(command_instance).to receive(:perform!).and_raise(Decidim::Commands::HookError)
    end

    it "broadcasts invalid" do
      expect { subject.call }.to broadcast(:invalid)
    end

    it "does not create a debate" do
      expect do
        subject.call
      end.not_to change(Decidim::Debates::Debate, :count)
    end
  end

  describe "events" do
    let(:author_follower) { create(:user, organization:) }
    let!(:author_follow) { create(:follow, followable: user, user: author_follower) }
    let(:space_follower) { create(:user, organization:) }
    let!(:space_follow) { create(:follow, followable: participatory_process, user: space_follower) }

    it "notifies the change to the author followers" do
      expect(Decidim::EventsManager)
        .to receive(:publish)
        .with(
          event: "decidim.events.debates.debate_created",
          event_class: Decidim::Debates::CreateDebateEvent,
          resource: kind_of(Decidim::Debates::Debate),
          followers: [author_follower],
          extra: { type: "user" }
        )
      expect(Decidim::EventsManager)
        .to receive(:publish)
        .with(
          event: "decidim.events.debates.debate_created",
          event_class: Decidim::Debates::CreateDebateEvent,
          resource: kind_of(Decidim::Debates::Debate),
          followers: [space_follower],
          extra: { type: "participatory_space" }
        )

      subject.call
    end
  end
end
