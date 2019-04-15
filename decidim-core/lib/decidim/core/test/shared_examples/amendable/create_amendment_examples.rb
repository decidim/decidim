# frozen_string_literal: true

shared_examples "create amendment" do
  context "when the form is valid" do
    it "broadcasts ok" do
      expect { command.call }.to broadcast(:ok)
    end

    it "creates an amendment and the emendation" do
      expect { command.call }
        .to change(Decidim::Amendment, :count)
        .by(1)
        .and change(amendable.resource_manifest.model_class_name.constantize, :count)
        .by(1)
    end

    it "traces the action", versioning: true do
      expect(Decidim.traceability)
        .to receive(:perform_action!)
        .with(
          "publish",
          form.amendable.amendable_type.constantize,
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

  context "when the form is invalid" do
    let(:title) { "Too short" }

    it "broadcasts invalid" do
      expect { command.call }.to broadcast(:invalid)
    end

    it "doesn't create an amendment and the emendation" do
      expect { command.call }
        .to change(Decidim::Amendment, :count)
        .by(0)
        .and change(amendable.resource_manifest.model_class_name.constantize, :count)
        .by(0)
    end
  end
end
