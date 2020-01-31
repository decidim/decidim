# frozen_string_literal: true

shared_examples "view proposal details from admin" do
  include ActionView::Helpers::TextHelper

  let(:address) { "Carrer Pare Llaurador 113, baixos, 08224 Terrassa" }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }
  let(:participatory_process) { create(:participatory_process, :with_steps, organization: organization, scope: participatory_process_scope) }
  let(:participatory_process_scope) { nil }

  before do
    stub_geocoding(address, [latitude, longitude])
  end

  it "has a link to the proposal" do
    go_to_admin_proposal_page(proposal)
    path = "processes/#{participatory_process.slug}/f/#{component.id}/proposals/#{proposal.id}"

    expect(page).to have_selector("a", text: path)
  end

  describe "with authors" do
    it "has a link to each author profile" do
      go_to_admin_proposal_page(proposal)

      within "#proposal-authors-list" do
        proposal.authors.each do |author|
          expect(page).to have_selector("a", text: author.name)
        end
      end
    end

    context "when it has an organization as an author" do
      let!(:proposal) { create :proposal, :official, component: current_component }

      it "doesn't show a link to the organization" do
        go_to_admin_proposal_page(proposal)

        within "#proposal-authors-list" do
          expect(page).to have_no_selector("a", text: "Official proposal")
          expect(page).to have_content("Official proposal")
        end
      end
    end
  end

  it "shows the proposal body" do
    go_to_admin_proposal_page(proposal)

    expect(page).to have_content(strip_tags(proposal.body).strip)
  end

  describe "with an specific creation date" do
    let!(:proposal) { create :proposal, component: current_component, created_at: Time.zone.parse("2020-01-29 15:00") }

    it "shows the proposal creation date" do
      go_to_admin_proposal_page(proposal)

      expect(page).to have_content("Creation date: 29/01/2020 15:00")
    end
  end

  describe "with supports" do
    before do
      create_list :proposal_vote, 2, proposal: proposal
    end

    it "shows the number of supports" do
      go_to_admin_proposal_page(proposal)

      expect(page).to have_content("Supports count: 2")
    end

    it "shows the ranking by supports" do
      another_proposal = create :proposal, component: component
      create :proposal_vote, proposal: another_proposal
      go_to_admin_proposal_page(proposal)

      expect(page).to have_content("Ranking by supports: 1 of")
    end
  end

  describe "with endorsements" do
    before do
      create_list :proposal_endorsement, 2, proposal: proposal
    end

    it "shows the number of endorsements" do
      go_to_admin_proposal_page(proposal)

      expect(page).to have_content("Endorsements count: 2")
    end

    it "shows the ranking by endorsements" do
      another_proposal = create :proposal, component: component
      create :proposal_endorsement, proposal: another_proposal
      go_to_admin_proposal_page(proposal)

      expect(page).to have_content("Ranking by endorsements: 1 of")
    end

    it "has a link to each endorser profile" do
      go_to_admin_proposal_page(proposal)

      within "#proposal-endorsers-list" do
        proposal.endorsements.for_listing.each do |endorsement|
          endorser = endorsement.normalized_author
          expect(page).to have_selector("a", text: endorser.name)
        end
      end
    end
  end

  it "shows the number of amendments" do
    create :proposal_amendment, amendable: proposal
    go_to_admin_proposal_page(proposal)

    expect(page).to have_content("Amendments count: 1")
  end

  describe "with comments" do
    before do
      create_list :comment, 2, commentable: proposal, alignment: -1
      create_list :comment, 3, commentable: proposal, alignment: 1
      create :comment, commentable: proposal, alignment: 0

      go_to_admin_proposal_page(proposal)
    end

    it "shows the number of comments" do
      expect(page).to have_content("Comments count: 6")
    end

    it "groups the number of comments by alignment" do
      within "#proposal-comments-alignment-count" do
        expect(page).to have_content("Favor: 3")
        expect(page).to have_content("Neutral: 1")
        expect(page).to have_content("Against: 2")
      end
    end
  end

  def go_to_admin_proposal_page(proposal)
    within find("tr", text: proposal.title) do
      click_link "Show"
    end
  end
end
