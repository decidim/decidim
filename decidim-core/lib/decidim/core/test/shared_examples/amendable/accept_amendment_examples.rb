# frozen_string_literal: true

shared_examples "accept amendment" do
  context "when the form is valid" do
    it "broadcasts ok" do
      expect { command.call }.to broadcast(:ok)
    end

    it "changes the emendation state to accepted" do
      expect { command.call }.to change(emendation, :state)
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
        .with(amendment, amendable.creator_author, state: "accepted")
        .and_call_original

      expect { command.call }.to change(Decidim::ActionLog, :count).by(1)
    end
  end
end
