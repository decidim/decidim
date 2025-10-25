# frozen_string_literal: true

shared_examples "close debate mutation examples" do
  context "when user cannot close the debate" do
    it "does not close the debate" do
      expect(response["close"]).to be_nil
    end
  end

  context "when user can close the debate" do
    let(:debate) { model }

    before do
      allow(debate).to receive(:closeable_by?).with(current_user).and_return(true)
    end

    it "closes the debate" do
      closed = response["close"]
      expect(closed).to be_present
      expect(closed).to include(
        {
          "id" => model.id.to_s,
          "conclusions" => {
            "translation" => conclusions[:en]
          },
          "closedAt" => model.reload.closed_at.to_time.iso8601
        }
      )
    end

    context "when conclusions are empty" do
      let(:conclusions) { { en: "" } }

      it "returns an error" do
        expect(response["close"]).to be_nil
      end
    end

    context "when conclusions are too short" do
      let(:conclusions) { { en: "Short" } }

      it "returns an error" do
        expect(response["close"]).to be_nil
      end
    end
  end
end
