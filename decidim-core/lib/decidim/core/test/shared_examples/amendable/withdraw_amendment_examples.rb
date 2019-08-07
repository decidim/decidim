# frozen_string_literal: true

shared_examples "withdraw amendment" do
  context "when current user is the author of the amendment" do
    let(:current_user) { amendment.amender }

    context "and the amendment has no supports" do
      it "withdraws the amendment" do
        expect { command.call }.to broadcast(:ok)
        expect(amendment.state).to eq("withdrawn")
        expect(emendation.state).to eq("withdrawn")
      end
    end

    context "and the amendment has some supports" do
      before do
        emendation.votes.create!(author: other_user)
      end

      it "is not able to withdraw the amendment" do
        expect { command.call }.to broadcast(:invalid)
        expect(amendment.state).not_to eq("withdrawn")
        expect(emendation.state).not_to eq("withdrawn")
      end
    end
  end

  context "when current user is not the author of the amendment" do
    let!(:current_user) { other_user }

    it "is not able to withdraw the amendment" do
      expect { command.call }.to broadcast(:invalid)
      expect(amendment.state).not_to eq("withdrawn")
      expect(emendation.state).not_to eq("withdrawn")
    end
  end
end
