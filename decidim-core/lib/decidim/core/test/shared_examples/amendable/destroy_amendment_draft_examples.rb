# frozen_string_literal: true

shared_examples "destroy amendment draft" do
  context "when current user is the author of the amendment" do
    let(:current_user) { amendment.amender }

    describe "and the amendment is a draft" do
      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "destroys the amendment and the emendation" do
        expect { command.call }
          .to change(Decidim::Amendment, :count)
          .by(-1)
          .and change(amendable.class, :count)
          .by(-1)
      end
    end

    describe "and the amendment is not a draft" do
      before do
        amendment.update(state: "evaluating")
      end

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end
    end
  end

  describe "when the current user is not the amender" do
    let!(:current_user) { other_user }

    it "broadcasts invalid" do
      expect { command.call }.to broadcast(:invalid)
    end
  end
end
