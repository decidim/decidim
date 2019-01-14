# frozen_string_literal: true

shared_examples "withdraw amendment" do
  context "when current user IS the author of the amendment" do
    context "and the amendment has no supports" do
      it "withdraws the amendment" do
        expect do
          expect { command.call }.to broadcast(:ok)
        end.to change { Decidim::Proposals::Proposal.count }.by(0)
        expect(emendation.amendment.state).to eq("withdrawn")
        expect(emendation.state).to eq("withdrawn")
      end
    end

    context "and the amendment HAS some supports" do
      before do
        emendation.votes.create!(author: current_user)
      end

      it "is not able to withdraw the amendment" do
        expect do
          expect { command.call }.to broadcast(:invalid)
        end.to change { Decidim::Proposals::Proposal.count }.by(0)
        expect(emendation.amendment.state).not_to eq("withdrawn")
        expect(emendation.state).not_to eq("withdrawn")
      end
    end
  end
end
