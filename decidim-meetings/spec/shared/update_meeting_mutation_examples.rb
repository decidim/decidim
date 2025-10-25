# frozen_string_literal: true

shared_examples "update meeting mutation examples" do
  context "when user has permission to update" do
    it "updates the meeting" do
      meeting_response = response["update"]
      expect(meeting_response).to be_present
      expect(meeting_response).to include(
        {
          "id" => model.id.to_s,
          "title" => {
            "translation" => title[:en]
          },
          "description" => {
            "translation" => description[:en]
          },
          "location" => {
            "translation" => location[:en]
          },
          "address" => address,
          "registrationType" => registration_type
        }
      )
      
      # Verify the meeting was actually updated in the database
      model.reload
      expect(model.title["en"]).to eq(title[:en])
      expect(model.description["en"]).to eq(description[:en])
      expect(model.address).to eq(address)
    end

    context "with invalid data" do
      let(:title) { { en: "" } }

      it "returns an error" do
        expect(response["update"]).to be_nil
        expect(response["errors"]).to be_present
      end
    end

    context "with partial update" do
      let(:variables) do
        {
          input: {
            attributes: {
              title: { en: "Only title updated" }
            }
          }
        }
      end

      it "updates only specified fields" do
        meeting_response = response["update"]
        expect(meeting_response).to be_present
        expect(meeting_response["title"]["translation"]).to eq("Only title updated")
      end
    end
  end
end
