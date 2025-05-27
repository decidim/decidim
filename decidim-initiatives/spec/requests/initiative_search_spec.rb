# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Initiative search" do
  subject { response.body }

  let(:organization) { create(:organization) }
  let(:type1) { create(:initiatives_type, organization:) }
  let(:type2) { create(:initiatives_type, organization:) }
  let(:scoped_type1) { create(:initiatives_type_scope, type: type1) }
  let(:scoped_type2) { create(:initiatives_type_scope, type: type2) }
  let(:user1) { create(:user, :confirmed, organization:, name: "John McDoggo", nickname: "john_mcdoggo") }
  let(:user2) { create(:user, :confirmed, organization:, nickname: "doggotrainer") }
  let(:area1) { create(:area, organization:) }
  let(:area2) { create(:area, organization:) }

  let!(:initiative1) { create(:initiative, id: 999_999, title: { en: "A doggo" }, scoped_type: scoped_type1, organization:) }
  let!(:initiative2) { create(:initiative, description: { en: "There is a doggo in the office" }, scoped_type: scoped_type2, organization:) }
  let!(:initiative3) { create(:initiative, organization:) }
  let!(:area1_initiative) { create(:initiative, organization:, area: area1) }
  let!(:area2_initiative) { create(:initiative, organization:, area: area2) }
  let!(:user1_initiative) { create(:initiative, organization:, author: user1) }
  let!(:user2_initiative) { create(:initiative, organization:, author: user2) }
  let!(:closed_initiative) { create(:initiative, :acceptable, organization:) }
  let!(:accepted_initiative) { create(:initiative, :accepted, organization:) }
  let!(:rejected_initiative) { create(:initiative, :rejected, organization:) }
  let!(:answered_rejected_initiative) { create(:initiative, :rejected, organization:, answered_at: Time.current) }
  let!(:created_initiative) { create(:initiative, :created, organization:) }
  let!(:user1_created_initiative) { create(:initiative, :created, organization:, author: user1, signature_start_date: Date.current + 2.days, signature_end_date: Date.current + 22.days) }

  let(:filter_params) { {} }
  let(:request_path) { decidim_initiatives.initiatives_path(locale: I18n.locale) }

  before do
    stub_const("Decidim::Paginable::OPTIONS", [100])
    get(
      request_path,
      params: { filter: filter_params },
      headers: { "HOST" => organization.host }
    )
  end

  it "displays all published open initiatives by default" do
    expect(subject).to include(decidim_escape_translated(initiative1.title))
    expect(subject).to include(decidim_escape_translated(initiative2.title))
    expect(subject).to include(decidim_escape_translated(initiative3.title))
    expect(subject).to include(decidim_escape_translated(area1_initiative.title))
    expect(subject).to include(decidim_escape_translated(area2_initiative.title))
    expect(subject).to include(decidim_escape_translated(user1_initiative.title))
    expect(subject).to include(decidim_escape_translated(user2_initiative.title))
    expect(subject).not_to include(decidim_escape_translated(closed_initiative.title))
    expect(subject).not_to include(decidim_escape_translated(accepted_initiative.title))
    expect(subject).not_to include(decidim_escape_translated(rejected_initiative.title))
    expect(subject).not_to include(decidim_escape_translated(answered_rejected_initiative.title))
    expect(subject).not_to include(decidim_escape_translated(created_initiative.title))
    expect(subject).not_to include(decidim_escape_translated(user1_created_initiative.title))
  end

  context "when filtering by text" do
    let(:filter_params) { { search_text_cont: search_text } }
    let(:search_text) { "doggo" }

    it "displays the initiatives containing the search in the title or the body or the author name or nickname" do
      expect(subject).to include(decidim_escape_translated(initiative1.title))
      expect(subject).to include(decidim_escape_translated(initiative2.title))
      expect(subject).not_to include(decidim_escape_translated(initiative3.title))
      expect(subject).not_to include(decidim_escape_translated(area1_initiative.title))
      expect(subject).not_to include(decidim_escape_translated(area2_initiative.title))
      expect(subject).to include(decidim_escape_translated(user1_initiative.title))
      expect(subject).to include(decidim_escape_translated(user2_initiative.title))
      expect(subject).not_to include(decidim_escape_translated(closed_initiative.title))
      expect(subject).not_to include(decidim_escape_translated(accepted_initiative.title))
      expect(subject).not_to include(decidim_escape_translated(rejected_initiative.title))
      expect(subject).not_to include(decidim_escape_translated(answered_rejected_initiative.title))
      expect(subject).not_to include(decidim_escape_translated(created_initiative.title))
      expect(subject).not_to include(decidim_escape_translated(user1_created_initiative.title))
    end

    context "and the search_text is an initiative id" do
      let(:search_text) { initiative1.id.to_s }

      it "returns the initiative with the searched id" do
        expect(subject).to include(decidim_escape_translated(initiative1.title))
        expect(subject).not_to include(decidim_escape_translated(initiative2.title))
        expect(subject).not_to include(decidim_escape_translated(initiative3.title))
        expect(subject).not_to include(decidim_escape_translated(area1_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(area2_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(user1_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(user2_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(closed_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(accepted_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(rejected_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(answered_rejected_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(created_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(user1_created_initiative.title))
      end
    end
  end

  context "when filtering by state" do
    let(:filter_params) { { with_any_state: state } }

    context "and state is open" do
      let(:state) { %w(open) }

      it "displays only open initiatives" do
        expect(subject).to include(decidim_escape_translated(initiative1.title))
        expect(subject).to include(decidim_escape_translated(initiative2.title))
        expect(subject).to include(decidim_escape_translated(initiative3.title))
        expect(subject).to include(decidim_escape_translated(area1_initiative.title))
        expect(subject).to include(decidim_escape_translated(area2_initiative.title))
        expect(subject).to include(decidim_escape_translated(user1_initiative.title))
        expect(subject).to include(decidim_escape_translated(user2_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(closed_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(accepted_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(rejected_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(answered_rejected_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(created_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(user1_created_initiative.title))
      end
    end

    context "and state is closed" do
      let(:state) { %w(closed) }

      it "displays only closed initiatives" do
        expect(subject).not_to include(decidim_escape_translated(initiative1.title))
        expect(subject).not_to include(decidim_escape_translated(initiative2.title))
        expect(subject).not_to include(decidim_escape_translated(initiative3.title))
        expect(subject).not_to include(decidim_escape_translated(area1_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(area2_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(user1_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(user2_initiative.title))
        expect(subject).to include(decidim_escape_translated(closed_initiative.title))
        expect(subject).to include(decidim_escape_translated(accepted_initiative.title))
        expect(subject).to include(decidim_escape_translated(rejected_initiative.title))
        expect(subject).to include(decidim_escape_translated(answered_rejected_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(created_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(user1_created_initiative.title))
      end
    end

    context "and state is accepted" do
      let(:state) { %w(accepted) }

      it "returns only accepted initiatives" do
        expect(subject).not_to include(decidim_escape_translated(initiative1.title))
        expect(subject).not_to include(decidim_escape_translated(initiative2.title))
        expect(subject).not_to include(decidim_escape_translated(initiative3.title))
        expect(subject).not_to include(decidim_escape_translated(area1_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(area2_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(user1_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(user2_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(closed_initiative.title))
        expect(subject).to include(decidim_escape_translated(accepted_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(rejected_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(answered_rejected_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(created_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(user1_created_initiative.title))
      end
    end

    context "and state is rejected" do
      let(:state) { %w(rejected) }

      it "returns only rejected initiatives" do
        expect(subject).not_to include(decidim_escape_translated(initiative1.title))
        expect(subject).not_to include(decidim_escape_translated(initiative2.title))
        expect(subject).not_to include(decidim_escape_translated(initiative3.title))
        expect(subject).not_to include(decidim_escape_translated(area1_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(area2_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(user1_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(user2_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(closed_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(accepted_initiative.title))
        expect(subject).to include(decidim_escape_translated(rejected_initiative.title))
        expect(subject).to include(decidim_escape_translated(answered_rejected_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(created_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(user1_created_initiative.title))
      end
    end

    context "and state is answered" do
      let(:state) { %w(answered) }

      it "returns only answered initiatives" do
        expect(subject).not_to include(decidim_escape_translated(initiative1.title))
        expect(subject).not_to include(decidim_escape_translated(initiative2.title))
        expect(subject).not_to include(decidim_escape_translated(initiative3.title))
        expect(subject).not_to include(decidim_escape_translated(area1_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(area2_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(user1_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(user2_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(closed_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(accepted_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(rejected_initiative.title))
        expect(subject).to include(decidim_escape_translated(answered_rejected_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(created_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(user1_created_initiative.title))
      end
    end

    context "and state is open or closed" do
      let(:state) { %w(open closed) }

      it "displays only closed initiatives" do
        expect(subject).to include(decidim_escape_translated(initiative1.title))
        expect(subject).to include(decidim_escape_translated(initiative2.title))
        expect(subject).to include(decidim_escape_translated(initiative3.title))
        expect(subject).to include(decidim_escape_translated(area1_initiative.title))
        expect(subject).to include(decidim_escape_translated(area2_initiative.title))
        expect(subject).to include(decidim_escape_translated(user1_initiative.title))
        expect(subject).to include(decidim_escape_translated(user2_initiative.title))
        expect(subject).to include(decidim_escape_translated(closed_initiative.title))
        expect(subject).to include(decidim_escape_translated(accepted_initiative.title))
        expect(subject).to include(decidim_escape_translated(rejected_initiative.title))
        expect(subject).to include(decidim_escape_translated(answered_rejected_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(created_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(user1_created_initiative.title))
      end
    end
  end

  context "when filtering by scope" do
    let(:filter_params) { { with_any_scope: scope_id } }

    context "and a single scope id is provided" do
      let(:scope_id) { [scoped_type1.scope.id] }

      it "displays initiatives by scope" do
        expect(subject).to include(decidim_escape_translated(initiative1.title))
        expect(subject).not_to include(decidim_escape_translated(initiative2.title))
        expect(subject).not_to include(decidim_escape_translated(initiative3.title))
        expect(subject).not_to include(decidim_escape_translated(area1_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(area2_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(user1_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(user2_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(closed_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(accepted_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(rejected_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(answered_rejected_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(created_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(user1_created_initiative.title))
      end
    end

    context "and multiple scope ids are provided" do
      let(:scope_id) { [scoped_type2.scope.id, scoped_type1.scope.id] }

      it "displays initiatives by scope" do
        expect(subject).to include(decidim_escape_translated(initiative1.title))
        expect(subject).to include(decidim_escape_translated(initiative2.title))
        expect(subject).not_to include(decidim_escape_translated(initiative3.title))
        expect(subject).not_to include(decidim_escape_translated(area1_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(area2_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(user1_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(user2_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(closed_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(accepted_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(rejected_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(answered_rejected_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(created_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(user1_created_initiative.title))
      end
    end
  end

  context "when filtering by author" do
    let(:filter_params) { { with_any_state: %w(open closed), author: } }

    before do
      login_as user1, scope: :user

      get(
        request_path,
        params: { filter: filter_params },
        headers: { "HOST" => organization.host }
      )
    end

    context "and author is any" do
      let(:author) { "any" }

      it "displays all initiatives except the created ones from other user" do
        expect(subject).to include(decidim_escape_translated(initiative1.title))
        expect(subject).to include(decidim_escape_translated(initiative2.title))
        expect(subject).to include(decidim_escape_translated(initiative3.title))
        expect(subject).to include(decidim_escape_translated(area1_initiative.title))
        expect(subject).to include(decidim_escape_translated(area2_initiative.title))
        expect(subject).to include(decidim_escape_translated(user1_initiative.title))
        expect(subject).to include(decidim_escape_translated(user2_initiative.title))
        expect(subject).to include(decidim_escape_translated(closed_initiative.title))
        expect(subject).to include(decidim_escape_translated(accepted_initiative.title))
        expect(subject).to include(decidim_escape_translated(rejected_initiative.title))
        expect(subject).to include(decidim_escape_translated(answered_rejected_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(created_initiative.title))
        expect(subject).to include(decidim_escape_translated(user1_created_initiative.title))
      end
    end

    context "and author is myself" do
      let(:author) { "myself" }

      it "contains only initiatives of the author, including their created upcoming initiative" do
        expect(subject).not_to include(decidim_escape_translated(initiative1.title))
        expect(subject).not_to include(decidim_escape_translated(initiative2.title))
        expect(subject).not_to include(decidim_escape_translated(initiative3.title))
        expect(subject).not_to include(decidim_escape_translated(area1_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(area2_initiative.title))
        expect(subject).to include(decidim_escape_translated(user1_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(user2_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(closed_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(accepted_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(rejected_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(answered_rejected_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(created_initiative.title))
        expect(subject).to include(decidim_escape_translated(user1_created_initiative.title))
      end
    end
  end

  context "when filtering by type" do
    let(:filter_params) { { with_any_type: type_id } }
    let(:type_id) { [initiative1.type.id] }

    it "displays initiatives of correct type" do
      expect(subject).to include(decidim_escape_translated(initiative1.title))
      expect(subject).not_to include(decidim_escape_translated(initiative2.title))
      expect(subject).not_to include(decidim_escape_translated(initiative3.title))
      expect(subject).not_to include(decidim_escape_translated(area1_initiative.title))
      expect(subject).not_to include(decidim_escape_translated(area2_initiative.title))
      expect(subject).not_to include(decidim_escape_translated(user1_initiative.title))
      expect(subject).not_to include(decidim_escape_translated(user2_initiative.title))
      expect(subject).not_to include(decidim_escape_translated(closed_initiative.title))
      expect(subject).not_to include(decidim_escape_translated(accepted_initiative.title))
      expect(subject).not_to include(decidim_escape_translated(rejected_initiative.title))
      expect(subject).not_to include(decidim_escape_translated(answered_rejected_initiative.title))
      expect(subject).not_to include(decidim_escape_translated(created_initiative.title))
      expect(subject).not_to include(decidim_escape_translated(user1_created_initiative.title))
    end

    context "and providing multiple types" do
      let(:type_id) { [initiative1.type.id, initiative2.type.id] }

      it "displays initiatives of correct type" do
        expect(subject).to include(decidim_escape_translated(initiative1.title))
        expect(subject).to include(decidim_escape_translated(initiative2.title))
        expect(subject).not_to include(decidim_escape_translated(initiative3.title))
        expect(subject).not_to include(decidim_escape_translated(area1_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(area2_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(user1_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(user2_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(closed_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(accepted_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(rejected_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(answered_rejected_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(created_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(user1_created_initiative.title))
      end
    end
  end

  context "when filtering by area" do
    let(:filter_params) { { with_any_area: area_id } }

    context "when an area id is being sent" do
      let(:area_id) { [area1.id.to_s] }

      it "displays initiatives by area" do
        expect(subject).not_to include(decidim_escape_translated(initiative1.title))
        expect(subject).not_to include(decidim_escape_translated(initiative2.title))
        expect(subject).not_to include(decidim_escape_translated(initiative3.title))
        expect(subject).to include(decidim_escape_translated(area1_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(area2_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(user1_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(user2_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(closed_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(accepted_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(rejected_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(answered_rejected_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(created_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(user1_created_initiative.title))
      end
    end

    context "and providing multiple ids" do
      let(:area_id) { [area1.id.to_s, area2.id.to_s] }

      it "displays initiatives by area" do
        expect(subject).not_to include(decidim_escape_translated(initiative1.title))
        expect(subject).not_to include(decidim_escape_translated(initiative2.title))
        expect(subject).not_to include(decidim_escape_translated(initiative3.title))
        expect(subject).to include(decidim_escape_translated(area1_initiative.title))
        expect(subject).to include(decidim_escape_translated(area2_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(user1_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(user2_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(closed_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(accepted_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(rejected_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(answered_rejected_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(created_initiative.title))
        expect(subject).not_to include(decidim_escape_translated(user1_created_initiative.title))
      end
    end
  end
end
