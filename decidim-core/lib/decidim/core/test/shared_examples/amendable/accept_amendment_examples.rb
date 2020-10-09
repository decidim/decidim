# frozen_string_literal: true

shared_examples "accept amendment" do
  context "when the form is valid" do
    it "broadcasts ok" do
      expect { command.call }.to broadcast(:ok)
    end

    it "changes the emendation state to accepted" do
      expect { command.call && emendation.reload }.to change(emendation, :state)
        .from("evaluating").to("accepted")
    end

    it "adds the emendation author as coauthor of the proposal" do
      expect { command.call }.to change { amendable.coauthorships.count }
        .from(1).to(2)
        .and change { amendable.authored_by?(emendation.creator_author) }
        .from(false).to(true)
    end

    it "traces the action", versioning: true do
      expect(Decidim.traceability)
        .to receive(:update!)
        .with(
          amendment,
          amendable.creator_author,
          { state: "accepted" },
          visibility: "public-only"
        ).and_return(amendment)

      expect(Decidim.traceability)
        .to receive(:perform_action!)
        .with(
          :update,
          amendable,
          emendation.creator_author,
          visibility: "public-only"
        ).and_call_original

      command.call
    end

    it "notifies the change" do
      expect(Decidim::EventsManager)
        .to receive(:publish)
        .with(
          event: "decidim.events.amendments.amendment_accepted",
          event_class: Decidim::Amendable::AmendmentAcceptedEvent,
          resource: emendation,
          followers: kind_of(Array),
          affected_users: kind_of(Array)
        )

      command.call
    end
  end
end
