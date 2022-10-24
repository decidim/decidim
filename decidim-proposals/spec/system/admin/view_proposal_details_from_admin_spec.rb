# frozen_string_literal: true

require "spec_helper"

describe "Admin views proposal details from admin", type: :system do
  include_context "when admin manages proposals"
  include ActionView::Helpers::TextHelper

  let(:address) { "Some address" }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }
  let(:participatory_process) { create(:participatory_process, :with_steps, organization:, scope: participatory_process_scope) }
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
    context "when the proposal's author is other user" do
      let!(:other_user) { create(:user, organization: current_component.organization) }
      let!(:proposal) { create :proposal, component: current_component, users: [other_user] }

      it "has a link to each author profile" do
        go_to_admin_proposal_page(proposal)

        within "#proposal-authors-list" do
          proposal.authors.each do |author|
            list_item = find("li", text: author.name)

            within list_item do
              expect(page).to have_selector("a", text: author.name)
              expect(page).to have_selector(:xpath, './/a[@title="Contact"]')
            end
          end
        end
      end
    end

    context "when the proposal's author is current user" do
      it "has a link to each author profile" do
        go_to_admin_proposal_page(proposal)

        within "#proposal-authors-list" do
          proposal.authors.each do |author|
            list_item = find("li", text: author.name)

            within list_item do
              expect(page).to have_selector("a", text: author.name)
            end
          end
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

    expect(page).to have_content(strip_tags(translated(proposal.body)).strip)
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
      create_list :proposal_vote, 2, proposal:
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
    let!(:endorsements) do
      2.times.collect do
        create(:endorsement, resource: proposal, author: build(:user, organization:))
      end
    end

    it "shows the number of endorsements" do
      go_to_admin_proposal_page(proposal)

      expect(page).to have_content("Endorsements count: 2")
    end

    it "shows the ranking by endorsements" do
      another_proposal = create :proposal, component: component
      create(:endorsement, resource: another_proposal, author: build(:user, organization:))
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

    context "with more than 5 endorsements" do
      let!(:endorsements) do
        6.times.collect do
          create(:endorsement, resource: proposal, author: build(:user, organization:))
        end
      end

      it "links to the proposal page to check the rest of endorsements" do
        go_to_admin_proposal_page(proposal)

        within "#proposal-endorsers-list" do
          expect(page).to have_selector("a", text: "and 1 more")
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

  context "with related meetings" do
    let(:meeting_component) { create :meeting_component, participatory_space: participatory_process }
    let(:meeting) { create :meeting, :published, component: meeting_component }
    let(:moderated_meeting) { create :meeting, component: meeting_component }
    let!(:moderation) { create(:moderation, reportable: moderated_meeting) }

    it "lists the related meetings" do
      proposal.link_resources(meeting, "proposals_from_meeting")
      go_to_admin_proposal_page(proposal)

      within "#related-meetings" do
        expect(page).to have_selector("a", text: translated(meeting.title))
      end
    end

    it "hides the moderated related meeting" do
      proposal.link_resources(moderated_meeting, "proposals_from_meeting")
      moderation.update(hidden_at: Time.current)

      go_to_admin_proposal_page(proposal)

      within "#related-meetings" do
        expect(page).not_to have_selector("a", text: translated(moderated_meeting.title))
      end
    end
  end

  context "with attached documents" do
    it "lists the documents" do
      document = create :attachment, :with_pdf, attached_to: proposal
      go_to_admin_proposal_page(proposal)

      within "#documents" do
        expect(page).to have_selector("a", text: translated(document.title))
        expect(page).to have_content(document.file_type)
      end
    end
  end

  context "with attached photos" do
    it "lists the documents" do
      image = create :attachment, :with_image, attached_to: proposal
      image.reload
      go_to_admin_proposal_page(proposal)

      within "#photos" do
        expect(page).to have_selector(:xpath, "//img[@src=\"#{image.thumbnail_url}\"]")
        expect(page).to have_selector(:xpath, "//a[@href=\"#{image.big_url}\"]")
      end
    end
  end

  def go_to_admin_proposal_page(proposal)
    within find("tr", text: translated(proposal.title)) do
      find("a", class: "action-icon--show-proposal").click
    end
  end
end
