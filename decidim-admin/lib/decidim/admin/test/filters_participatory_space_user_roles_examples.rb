# frozen_string_literal: true

shared_examples "sortable participatory space user roles" do
  context "when sorting by name" do
    context "when desc" do
      let(:sort_by) { "name desc" }

      it "displays the result" do
        expect(page).to have_content(user.name)
      end
    end

    context "when asc" do
      let(:sort_by) { "name asc" }

      it "displays the result" do
        expect(page).not_to have_content(user.name)
      end
    end
  end

  context "when sorting by email" do
    context "when desc" do
      let(:sort_by) { "email desc" }

      it "displays the result" do
        expect(page).to have_content(user.name)
      end
    end

    context "when asc" do
      let(:sort_by) { "email asc" }

      it "displays the result" do
        expect(page).not_to have_content(user.name)
      end
    end
  end

  context "when sorting by last_sign_in_at" do
    context "when desc" do
      let(:sort_by) { "last_sign_in_at desc" }

      it "displays the result" do
        expect(page).to have_content(user.name)
      end
    end

    context "when asc" do
      let(:sort_by) { "last_sign_in_at asc" }

      it "displays the result" do
        expect(page).not_to have_content(user.name)
      end
    end
  end

  context "when sorting by invitation_accepted_at" do
    context "when desc" do
      let(:sort_by) { "invitation_accepted_at desc" }

      it "displays the result" do
        expect(page).to have_content(user.name)
      end
    end

    context "when asc" do
      let(:sort_by) { "invitation_accepted_at asc" }

      it "displays the result" do
        expect(page).not_to have_content(user.name)
      end
    end
  end

  context "when sorting by role" do
    context "when desc" do
      let(:sort_by) { "role desc" }

      it "displays the result" do
        expect(page).to have_content(user.name)
      end
    end

    context "when asc" do
      let(:sort_by) { "role asc" }

      it "displays the result" do
        expect(page).not_to have_content(user.name)
      end
    end
  end
end

shared_examples "filterable participatory space user roles" do
  context "when filtering by invite Accepted" do
    context "when filtering by null" do
      it "returns participatory space users" do
        apply_filter("Invite accepted", "Yes")

        within ".stack tbody" do
          expect(page).to have_content(invited_user2.name)
          expect(page).to have_css("tr", count: 1)
        end
      end
    end

    context "when filtering by not null" do
      it "returns participatory space users" do
        apply_filter("Invite accepted", "No")

        within ".stack tbody" do
          expect(page).to have_content(invited_user1.name)
          expect(page).to have_css("tr", count: 1)
        end
      end
    end
  end

  context "when filtering by logged in" do
    context "when filtering by null" do
      it "returns participatory space users" do
        apply_filter("Ever logged in", "Yes")

        within ".stack tbody" do
          expect(page).to have_content(invited_user2.name)
          expect(page).to have_css("tr", count: 1)
        end
      end
    end

    context "when filtering by not null" do
      it "returns participatory space users" do
        apply_filter("Ever logged in", "No")

        within ".stack tbody" do
          expect(page).to have_content(invited_user1.name)
          expect(page).to have_css("tr", count: 1)
        end
      end
    end
  end
end

shared_examples "searchable participatory space user roles" do
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
