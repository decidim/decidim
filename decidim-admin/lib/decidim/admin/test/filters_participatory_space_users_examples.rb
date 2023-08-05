# frozen_string_literal: true

shared_examples "filterable participatory space users" do
  let!(:filtered_results_table_selector) { "table.table-list tbody" }

  context "when filtering by invitation sent at" do
    context "when filtering by null" do
      it "returns participatory space users" do
        apply_filter("Invitation sent", "Not sent")

        within filtered_results_table_selector do
          expect(page).to have_content(invited_user2.name)
          expect(page).to have_css("tr", count: 1)
        end
      end
    end

    context "when filtering by not null" do
      it "returns participatory space users" do
        apply_filter("Invitation sent", "Sent")

        within filtered_results_table_selector do
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

        within filtered_results_table_selector do
          expect(page).to have_content(invited_user2.name)
          expect(page).to have_css("tr", count: 1)
        end
      end
    end

    context "when filtering by not null" do
      it "returns participatory space users" do
        apply_filter("Invitation accepted", "Accepted")

        within filtered_results_table_selector do
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

      within filtered_results_table_selector do
        expect(page).to have_content(name)
        expect(page).to have_css("tr", count: 1)
      end
    end

    it "can be searched by email" do
      search_by_text(email)

      within filtered_results_table_selector do
        expect(page).to have_content(email)
        expect(page).to have_css("tr", count: 1)
      end
    end
  end
end
