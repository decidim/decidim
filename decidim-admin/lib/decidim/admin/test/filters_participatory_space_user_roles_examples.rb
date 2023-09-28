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
      include_examples "admin is filtering participatory space users", label: "Invite accepted", value: "Yes" do
        let(:compare_with) { invited_user2.name }
      end
    end

    context "when filtering by not null" do
      include_examples "admin is filtering participatory space users", label: "Invite accepted", value: "No" do
        let(:compare_with) { invited_user1.name }
      end
    end
  end

  context "when filtering by logged in" do
    context "when filtering by null" do
      include_examples "admin is filtering participatory space users", label: "Ever logged in", value: "Yes" do
        let(:compare_with) { invited_user2.name }
      end
    end

    context "when filtering by not null" do
      include_examples "admin is filtering participatory space users", label: "Ever logged in", value: "No" do
        let(:compare_with) { invited_user1.name }
      end
    end
  end
end

shared_examples "searchable participatory space user roles" do
  context "when searching by name or nickname or email" do
    include_examples "admin is searching participatory space users" do
      let(:value) { name }
    end
    include_examples "admin is searching participatory space users" do
      let(:value) { email }
    end
  end
end
