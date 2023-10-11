# frozen_string_literal: true

shared_examples "admin is filtering participatory space users" do |label:, value:|
  it "returns participatory space users" do
    apply_filter(label, value)

    within ".table-list tbody" do
      expect(page).to have_content(compare_with)
      expect(page).to have_css("tr", count: 1)
    end
  end
end

shared_examples "admin is searching participatory space users" do
  it "returns participatory space users" do
    search_by_text(value)

    within ".table-list tbody" do
      expect(page).to have_content(value)
      expect(page).to have_css("tr", count: 1)
    end
  end
end

shared_examples "filterable participatory space users" do
  context "when filtering by invitation sent at" do
    context "when filtering by null" do
      include_examples "admin is filtering participatory space users", label: "Invitation sent", value: "Not sent" do
        let(:compare_with) { invited_user2.name }
      end
    end

    context "when filtering by not null" do
      include_examples "admin is filtering participatory space users", label: "Invitation sent", value: "Sent" do
        let(:compare_with) { invited_user1.name }
      end
    end
  end

  context "when filtering by invitation accepted at" do
    context "when filtering by null" do
      include_examples "admin is filtering participatory space users", label: "Invitation accepted", value: "Not accepted" do
        let(:compare_with) { invited_user2.name }
      end
    end

    context "when filtering by not null" do
      include_examples "admin is filtering participatory space users", label: "Invitation accepted", value: "Accepted" do
        let(:compare_with) { invited_user1.name }
      end
    end
  end
end

shared_examples "searchable participatory space users" do
  context "when searching by name or nickname or email" do
    include_examples "admin is searching participatory space users" do
      let(:value) { name }
    end
    include_examples "admin is searching participatory space users" do
      let(:value) { email }
    end
  end
end
