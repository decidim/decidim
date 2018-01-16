# frozen_string_literal: true

shared_examples "manage proposal notes" do
  let(:body) { "Awesome body of proposal note" }

  describe "Index" do
    it "shows all proposal notes for the given proposal" do
      expect(page).to have_selector("form")

      proposal_notes.each do |proposal_note|
        expect(page).to have_content("Awesome note to admin")
      end
    end

    it "creates a new meeting", :slow do

      fill_in :proposal_note_body, with: body

      within ".new_proposal_note" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      expect(page).to have_content("Awesome body of proposal note")
    end

  end



end
