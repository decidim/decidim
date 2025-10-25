# frozen_string_literal: true

shared_examples "manage debate mutation examples" do
  context "when user is not the author" do
    it "does not update the debate" do
      expect(response["update"]).to be_nil
    end
  end

  context "when user is the author" do
    let!(:debate_author) { user }

    it "updates the debate" do
      update = response["update"]
      expect(update).to be_present
      expect(update).to include(
        {
          "id" => model.id.to_s,
          "title" => {
            "translation" => title
          },
          "description" => {
            "translation" => description
          }
        }
      )
    end

    context "with taxonomies" do
      let(:taxonomy_ids) { taxonomies.map(&:id) }

      it "updates the debate with taxonomies" do
        update = response["update"]
        expect(update).to be_present
        expect(model.reload.taxonomies.pluck(:id)).to match_array(taxonomy_ids)
      end
    end
  end
end
