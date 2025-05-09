# frozen_string_literal: true

require "spec_helper"

describe "Admin views proposal details from admin" do
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

    within ".component__show_nav" do
      expect(page).to have_link("See proposal", href: /#{path}/)
    end
  end

  describe "with authors" do
    context "when the proposal's author is other user" do
      let!(:other_user) { create(:user, organization: current_component.organization) }
      let!(:proposal) { create(:proposal, component: current_component, users: [other_user]) }

      it "has a link to each author profile" do
        go_to_admin_proposal_page(proposal)

        within ".component__show_nav-author" do
          proposal.authors.each do |author|
            list_item = find("li", text: author.name)

            within list_item do
              expect(page).to have_css("a", text: author.name)
              expect(page).to have_xpath('.//a[@title="Contact"]')
            end
          end
        end
      end
    end

    context "when the proposal's author is current user" do
      it "has a link to each author profile" do
        go_to_admin_proposal_page(proposal)

        within ".component__show_nav-author" do
          proposal.authors.each do |author|
            list_item = find("li", text: author.name)

            within list_item do
              expect(page).to have_css("a", text: author.name)
            end
          end
        end
      end
    end

    context "when it has an organization as an author" do
      let!(:proposal) { create(:proposal, :official, component: current_component) }

      it "does not show a link to the organization" do
        go_to_admin_proposal_page(proposal)

        within ".component__show_nav-author-title" do
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
    let!(:proposal) { create(:proposal, component: current_component, created_at: Time.zone.parse("2020-01-29 15:00")) }

    it "shows the proposal creation date" do
      go_to_admin_proposal_page(proposal)

      expect(page).to have_css(".component__show_nav-author-date", text: "29/01/2020 15:00")
    end
  end

  describe "with votes" do
    before do
      create_list(:proposal_vote, 2, proposal:)
    end

    it "shows the number of votes" do
      go_to_admin_proposal_page(proposal)

      expect(page).to have_css("[data-votes] [data-count]", text: "2")
    end

    it "shows the ranking by votes" do
      another_proposal = create(:proposal, component:)
      create(:proposal_vote, proposal: another_proposal)
      go_to_admin_proposal_page(proposal)

      expect(page).to have_css("[data-votes] [data-ranking]", text: "1 of ")
    end
  end

  describe "with likes" do
    context "when there is not any likes" do
      it "does not show the title" do
        go_to_admin_proposal_page(proposal)

        expect(page).to have_no_content "Likes"
      end
    end

    context "when there are likes" do
      let!(:likes) do
        # We cannot use `create_list`, as it gives a "Validation failed: Resource has already been taken"
        2.times.collect do
          create(:like, resource: proposal, author: build(:user, organization:))
        end
      end

      it "shows the number of likes" do
        go_to_admin_proposal_page(proposal)

        expect(page).to have_content "Likes"
        expect(page).to have_css("[data-likes] [data-count]", text: "2")
      end

      it "shows the ranking by likes" do
        another_proposal = create(:proposal, component:)
        create(:like, resource: another_proposal, author: build(:user, organization:))
        go_to_admin_proposal_page(proposal)

        expect(page).to have_css("[data-likes] [data-ranking]", text: "1 of ")
      end

      it "has a link to each endorser profile" do
        go_to_admin_proposal_page(proposal)

        within "#proposal-likes-list" do
          proposal.likes.for_listing.each do |like|
            endorser = like.author
            expect(page).to have_css("a", text: endorser.name)
          end
        end
      end

      context "with more than 5 likes" do
        let!(:likes) do
          # We cannot use `create_list`, as it gives a "Validation failed: Resource has already been taken"
          6.times.collect do
            create(:like, resource: proposal, author: build(:user, organization:))
          end
        end

        it "links to the proposal page to check the rest of likes" do
          go_to_admin_proposal_page(proposal)

          within "#proposal-likes-list" do
            expect(page).to have_css("a", text: "and 1 more")
          end
        end
      end
    end
  end

  it "shows the number of amendments" do
    create(:proposal_amendment, amendable: proposal)
    go_to_admin_proposal_page(proposal)

    expect(page).to have_css("[data-amendments] [data-count]", text: "1")
  end

  describe "with comments" do
    before do
      create_list(:comment, 2, commentable: proposal, alignment: -1)
      create_list(:comment, 3, commentable: proposal, alignment: 1)
      create(:comment, commentable: proposal, alignment: 0)

      go_to_admin_proposal_page(proposal)
    end

    it "shows the number of comments" do
      expect(page).to have_css("[data-comments] [data-count]", text: "6")
    end

    it "groups the number of comments by alignment" do
      within "#proposal-comments-alignment-count" do
        expect(page).to have_css("[data-comments] [data-positive]", text: "3")
        expect(page).to have_css("[data-comments] [data-neutral]", text: "1")
        expect(page).to have_css("[data-comments] [data-negative]", text: "2")
      end
    end
  end

  context "with related meetings" do
    context "when there is not any meeting" do
      it "does not show the title" do
        go_to_admin_proposal_page(proposal)

        expect(page).to have_no_content "Related meetings"
      end
    end

    context "when there are meetings" do
      let(:meeting_component) { create(:meeting_component, participatory_space: participatory_process) }
      let(:meeting) { create(:meeting, :published, component: meeting_component) }
      let(:moderated_meeting) { create(:meeting, component: meeting_component) }
      let!(:moderation) { create(:moderation, reportable: moderated_meeting) }

      it "lists the related meetings" do
        proposal.link_resources(meeting, "proposals_from_meeting")
        go_to_admin_proposal_page(proposal)

        within "#related-meetings" do
          expect(page).to have_css("a", text: translated(meeting.title))
        end
      end

      it "hides the moderated related meeting" do
        proposal.link_resources(moderated_meeting, "proposals_from_meeting")
        moderation.update(hidden_at: Time.current)

        go_to_admin_proposal_page(proposal)

        expect(page).to have_no_content "Related meetings"
      end
    end
  end

  context "with attached documents" do
    it "lists the documents" do
      document = create(:attachment, :with_pdf, attached_to: proposal)
      go_to_admin_proposal_page(proposal)

      within "#documents" do
        expect(page).to have_css("a", text: translated(document.title))
        expect(page).to have_content(document.file_type)
      end
    end
  end

  context "with attached photos" do
    it "lists the documents" do
      image = create(:attachment, :with_image, attached_to: proposal)
      image.reload
      go_to_admin_proposal_page(proposal)

      within "#photos" do
        img = page.find("img")
        expect(img["src"]).to be_blob_url(image.file.blob)
      end
    end
  end

  def go_to_admin_proposal_page(proposal)
    within "tr", text: translated(proposal.title) do
      find("a", class: "action-icon--show-proposal").click
    end
  end
end
