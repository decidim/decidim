# frozen_string_literal: true

require "spec_helper"

describe Decidim::Debates::Admin::CreateDebate do
  subject { described_class.new(form) }

  let(:organization) { create(:organization, available_locales: [:en, :ca, :es], default_locale: :en) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:current_component) { create(:component, participatory_space: participatory_process, manifest_name: "debates") }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:comments_layout) { "single_column" }
  let(:attachments) { [] }
  let(:taxonomizations) do
    2.times.map { build(:taxonomization, taxonomy: create(:taxonomy, :with_parent, organization:), taxonomizable: nil) }
  end
  let(:form) do
    double(
      invalid?: invalid,
      title: { en: "title" },
      description: { en: "description" },
      information_updates: { en: "information updates" },
      instructions: { en: "instructions" },
      start_time: 1.day.from_now,
      end_time: 1.day.from_now + 1.hour,
      taxonomizations:,
      current_user: user,
      current_component:,
      component: current_component,
      current_organization: organization,
      finite:,
      comments_enabled: true,
      comments_layout:,
      add_documents: attachments,
      documents: [],
      errors: ActiveModel::Errors.new(self)
    )
  end
  let(:finite) { true }
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

    context "when debate is open" do
      let(:finite) { false }

      it "creates an open debate" do
        subject.call
        expect(debate.start_time).not_to be_present
        expect(debate.end_time).not_to be_present
      end
    end

    it "sets the taxonomies" do
      subject.call
      expect(debate.taxonomizations).to match_array(form.taxonomizations)
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

    it "sets the organization as author" do
      subject.call

      expect(debate.author).to eq(organization)
    end

    it "traces the action", versioning: true do
      expect(Decidim.traceability)
        .to receive(:create!)
        .with(
          Decidim::Debates::Debate,
          user,
          hash_including(:taxonomizations, :title, :description, :information_updates, :instructions, :end_time, :start_time, :component),
          visibility: "all"
        )
        .and_call_original

      expect { subject.call }.to change(Decidim::ActionLog, :count)
      action_log = Decidim::ActionLog.last
      expect(action_log.version).to be_present
      expect(action_log.version.event).to eq "create"
    end

    describe "events" do
      let(:space_follower) { create(:user, organization:) }
      let!(:space_follow) { create(:follow, followable: participatory_process, user: space_follower) }

      it "notifies the change to the author followers" do
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

    context "when creating a debate with a single column layout" do
      let(:comments_layout) { "single_column" }

      it "creates a debate with a single column layout for comments" do
        subject.call
        expect(debate.comments_layout).to eq("single_column")
      end
    end

    context "when creating a debate with a two columns layout" do
      let(:comments_layout) { "two_columns" }

      it "creates a debate with a two columns layout for comments" do
        subject.call
        expect(debate.comments_layout).to eq("two_columns")
      end
    end
  end

  describe "when debate with attachments" do
    let(:debate) { Decidim::Debates::Debate.last }
    let(:current_component) { create(:component, participatory_space: participatory_process, manifest_name: "debates", settings: { "attachments_allowed" => true }) }
    let(:attachments) do
      [
        { file: upload_test_file(Decidim::Dev.asset("city.jpeg"), content_type: "image/jpeg") },
        { file: upload_test_file(Decidim::Dev.asset("Exampledocument.pdf"), content_type: "application/pdf") }
      ]
    end

    it "creates the debate with attachments" do
      expect { subject.call }.to change(Decidim::Debates::Debate, :count).by(1) & change(Decidim::Attachment, :count).by(2)
      expect(debate.attachments.map(&:weight)).to eq([1, 2])

      debate_attachments = debate.attachments
      expect(debate_attachments.count).to eq(2)
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

    context "when ActiveRecord::RecordInvalid is raised" do
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

    context "when Decidim::Commands::HookError is raised" do
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
  end
end
