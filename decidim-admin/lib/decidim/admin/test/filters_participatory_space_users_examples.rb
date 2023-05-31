# frozen_string_literal: true

shared_examples "filterable participatory space users" do
  context "when filtering by invitation sent at" do
    context "when filtering by null" do
      it "returns participatory space users" do
        apply_filter("Invitation sent", "Not sent")

        within ".stack tbody" do
          expect(page).to have_content(invited_user2.name)
          expect(page).to have_css("tr", count: 1)
        end
      end
    end

    context "when filtering by not null" do
      it "returns participatory space users" do
        apply_filter("Invitation sent", "Sent")

        within ".stack tbody" do
          expect(page).to have_content(invited_user1.name)
          expect(page).to have_css("tr", count: 1)
        end
      end
    end
  end

  context "when filtering by invitation accepted at" do
    context "when filtering by null" do
      it "returns participatory space users" do
        apply_filter("Invitation accepted", "Not accepted")

        within ".stack tbody" do
          expect(page).to have_content(invited_user2.name)
          expect(page).to have_css("tr", count: 1)
        end
      end
    end

    context "when filtering by not null" do
      it "returns participatory space users" do
        apply_filter("Invitation accepted", "Accepted")

        within ".stack tbody" do
          expect(page).to have_content(invited_user1.name)
          expect(page).to have_css("tr", count: 1)
        end
      end
    end
  end
end

shared_examples "searchable participatory space users" do
  context "when searching by name or nickname or email" do
    it "can be searched by name" do
      search_by_text(name)

      within ".stack tbody" do
        expect(page).to have_content(name)
        expect(page).to have_css("tr", count: 1)
      end
    end

    it "can be searched by email" do
      search_by_text(email)

      within ".stack tbody" do
        expect(page).to have_content(email)
        expect(page).to have_css("tr", count: 1)
      end
    end
  end
end
