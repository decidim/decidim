# frozen_string_literal: true

shared_examples "publish amendment draft" do
  describe "when the form is valid" do
    it "broadcasts ok" do
      expect { command.call }.to broadcast(:ok)
    end

    it "publishes the amendment and the emendation" do
      command.call

      expect(Decidim::Amendment.last.draft?).to eq(false)
      expect(amendable.class.last.published?).to eq(true)
    end

    it "traces the action", versioning: true do
      expect(Decidim.traceability)
        .to receive(:perform_action!)
        .with(
          "publish",
          form.amendable.class,
          form.current_user,
          kind_of(Hash)
        ).and_call_original

      expect { command.call }.to change(Decidim::ActionLog, :count).by(1)
    end

    it "notifies the change" do
      expect(Decidim::EventsManager)
        .to receive(:publish)
        .with(
          event: "decidim.events.amendments.amendment_created",
          event_class: Decidim::Amendable::AmendmentCreatedEvent,
          resource: amendable,
          affected_users: [amendable.creator_author],
          followers: []
        )

      command.call
    end
  end

  context "when the form is not valid" do
    let(:form) { Decidim::Amendable::PublishForm.from_params(id: nil) }

    it "broadcasts invalid" do
      expect { command.call }.to broadcast(:invalid)
    end
  end

  context "when current user is not the author of the amendment" do
    let(:current_user) { other_user }

    it "broadcasts invalid" do
      expect { command.call }.to broadcast(:invalid)
    end
  end

  context "when amendment is not a draft" do
    before do
      amendment.update(state: "evaluating")
    end

    it "broadcasts invalid" do
      expect { command.call }.to broadcast(:invalid)
    end
  end
end
