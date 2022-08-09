# frozen_string_literal: true

require "spec_helper"

describe "Proposals", type: :system do
  include ActionView::Helpers::TextHelper
  include_context "with a component"
  let(:manifest_name) { "proposals" }

  let!(:category) { create :category, participatory_space: participatory_process }
  let!(:scope) { create :scope, organization: }
  let!(:user) { create :user, :confirmed, organization: }
  let(:scoped_participatory_process) { create(:participatory_process, :with_steps, organization:, scope:) }

  let(:address) { "Some address" }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }

  let(:proposal_title) { translated(proposal.title) }

  before do
    stub_geocoding(address, [latitude, longitude])
  end

  matcher :have_author do |name|
    match { |node| node.has_selector?(".author-data", text: name) }
    match_when_negated { |node| node.has_no_selector?(".author-data", text: name) }
  end

  matcher :have_creation_date do |date|
    match { |node| node.has_selector?(".author-data__extra", text: date) }
    match_when_negated { |node| node.has_no_selector?(".author-data__extra", text: date) }
  end

  context "when viewing a single proposal" do
    let!(:component) do
      create(:proposal_component,
             manifest:,
             participatory_space: participatory_process,
             settings: {
               scopes_enabled: true,
               scope_id: participatory_process.scope&.id
             })
    end

    let!(:proposals) { create_list(:proposal, 3, component:) }
    let!(:proposal) { proposals.first }

    it_behaves_like "accessible page" do
      before do
        visit_component
        click_link proposal_title
      end
    end

    it "allows viewing a single proposal" do
      visit_component

      click_link proposal_title

      expect(page).to have_content(proposal_title)
      expect(page).to have_content(strip_tags(translated(proposal.body)).strip)
      expect(page).to have_author(proposal.creator_author.name)
      expect(page).to have_content(proposal.reference)
      expect(page).to have_creation_date(I18n.l(proposal.published_at, format: :decidim_short))
    end

    context "when process is not related to any scope" do
      let!(:proposal) { create(:proposal, component:, scope:) }

      it "can be filtered by scope" do
        visit_component
        click_link proposal_title
        expect(page).to have_content(translated(scope.name))
      end
    end

    context "when process is related to a child scope" do
      let!(:proposal) { create(:proposal, component:, scope:) }
      let(:participatory_process) { scoped_participatory_process }

      it "does not show the scope name" do
        visit_component
        click_link proposal_title
        expect(page).to have_no_content(translated(scope.name))
      end
    end

    context "when it is an official proposal" do
      let(:content) { generate_localized_title }
      let!(:official_proposal) { create(:proposal, :official, body: content, component:) }
      let!(:official_proposal_title) { translated(official_proposal.title) }

      before do
        visit_component
        click_link official_proposal_title
      end

      it "shows the author as official" do
        expect(page).to have_content("Official proposal")
      end

      it_behaves_like "rendering safe content", ".columns.mediumlarge-8.large-9"
    end

    context "when rich text editor is enabled for participants" do
      let!(:proposal) { create(:proposal, body: content, component:) }

      before do
        organization.update(rich_text_editor_in_public_views: true)
        visit_component
        click_link proposal_title
      end

      it_behaves_like "rendering safe content", ".columns.mediumlarge-8.large-9"
    end

    context "when rich text editor is NOT enabled for participants" do
      let!(:proposal) { create(:proposal, body: content, component:) }

      before do
        visit_component
        click_link proposal_title
      end

      it_behaves_like "rendering unsafe content", ".columns.mediumlarge-8.large-9"
    end

    context "when it is a proposal with image" do
      let!(:component) do
        create(:proposal_component,
               manifest:,
               participatory_space: participatory_process)
      end

      let!(:proposal) { create(:proposal, component:) }
      let!(:image) { create(:attachment, attached_to: proposal) }

      it "shows the card image" do
        visit_component
        within "#proposal_#{proposal.id}" do
          expect(page).to have_selector(".card__image")
        end
      end
    end

    context "when it is an official meeting proposal" do
      include_context "with rich text editor content"
      let!(:proposal) { create(:proposal, :official_meeting, body: content, component:) }

      before do
        visit_component
        click_link proposal_title
      end

      it "shows the author as meeting" do
        expect(page).to have_content(translated(proposal.authors.first.title))
      end

      it_behaves_like "rendering safe content", ".columns.mediumlarge-8.large-9"
    end

    context "when a proposal has comments" do
      let(:proposal) { create(:proposal, component:) }
      let(:author) { create(:user, :confirmed, organization: component.organization) }
      let!(:comments) { create_list(:comment, 3, commentable: proposal) }

      it "shows the comments" do
        visit_component
        click_link proposal_title

        comments.each do |comment|
          expect(page).to have_content(comment.body.values.first)
        end
      end
    end

    context "when a proposal has costs" do
      let!(:proposal) do
        create(
          :proposal,
          :accepted,
          :with_answer,
          component:,
          cost: 20_000,
          cost_report: { en: "My cost report" },
          execution_period: { en: "My execution period" }
        )
      end
      let!(:author) { create(:user, :confirmed, organization: component.organization) }

      it "shows the costs" do
        component.update!(
          step_settings: {
            component.participatory_space.active_step.id => {
              answers_with_costs: true
            }
          }
        )

        visit_component
        click_link proposal_title

        expect(page).to have_content("20,000.00")
        expect(page).to have_content("MY EXECUTION PERIOD")
        expect(page).to have_content("My cost report")
      end
    end

    context "when a proposal has been linked in a meeting" do
      let(:proposal) { create(:proposal, component:) }
      let(:meeting_component) do
        create(:component, manifest_name: :meetings, participatory_space: proposal.component.participatory_space)
      end
      let(:meeting) { create(:meeting, :published, component: meeting_component) }

      before do
        meeting.link_resources([proposal], "proposals_from_meeting")
      end

      it "shows related meetings" do
        visit_component
        click_link proposal_title

        expect(page).to have_i18n_content(meeting.title)
      end
    end

    context "when a proposal has been linked in a result" do
      let(:proposal) { create(:proposal, component:) }
      let(:accountability_component) do
        create(:component, manifest_name: :accountability, participatory_space: proposal.component.participatory_space)
      end
      let(:result) { create(:result, component: accountability_component) }

      before do
        result.link_resources([proposal], "included_proposals")
      end

      it "shows related resources" do
        visit_component
        click_link proposal_title

        expect(page).to have_i18n_content(result.title)
      end
    end

    context "when a proposal is in evaluation" do
      let!(:proposal) { create(:proposal, :with_answer, :evaluating, component:) }

      it "shows a badge and an answer" do
        visit_component
        click_link proposal_title

        expect(page).to have_content("Evaluating")

        within ".callout.warning.js-announcement" do
          expect(page).to have_content("This proposal is being evaluated")
          expect(page).to have_i18n_content(proposal.answer)
        end
      end
    end

    context "when a proposal has been rejected" do
      let!(:proposal) { create(:proposal, :with_answer, :rejected, component:) }

      it "shows the rejection reason" do
        visit_component
        uncheck "Accepted"
        uncheck "Evaluating"
        uncheck "Not answered"
        page.find_link(proposal_title, wait: 30)
        click_link proposal_title

        expect(page).to have_content("Rejected")

        within ".callout.alert.js-announcement" do
          expect(page).to have_content("This proposal has been rejected")
          expect(page).to have_i18n_content(proposal.answer)
        end
      end
    end

    context "when a proposal has been accepted" do
      let!(:proposal) { create(:proposal, :with_answer, :accepted, component:) }

      it "shows the acceptance reason" do
        visit_component
        click_link proposal_title

        expect(page).to have_content("Accepted")

        within ".callout.success.js-announcement" do
          expect(page).to have_content("This proposal has been accepted")
          expect(page).to have_i18n_content(proposal.answer)
        end
      end
    end

    context "when the proposal answer has not been published" do
      let!(:proposal) { create(:proposal, :accepted_not_published, component:) }

      it "shows the acceptance reason" do
        visit_component
        click_link proposal_title

        expect(page).not_to have_content("Accepted")
        expect(page).not_to have_content("This proposal has been accepted")
        expect(page).not_to have_i18n_content(proposal.answer)
      end
    end

    context "when the proposals'a author account has been deleted" do
      let(:proposal) { proposals.first }

      before do
        Decidim::DestroyAccount.call(proposal.creator_author, Decidim::DeleteAccountForm.from_params({}))
      end

      it "the user is displayed as a deleted user" do
        visit_component

        click_link proposal_title

        expect(page).to have_content("Participant deleted")
      end
    end
  end

  context "when a proposal has been linked in a project" do
    let(:component) do
      create(:proposal_component,
             manifest:,
             participatory_space: participatory_process)
    end
    let(:proposal) { create(:proposal, component:) }
    let(:budget_component) do
      create(:component, manifest_name: :budgets, participatory_space: proposal.component.participatory_space)
    end
    let(:project) { create(:project, component: budget_component) }

    before do
      project.link_resources([proposal], "included_proposals")
    end

    it "shows related projects" do
      visit_component
      click_link proposal_title

      expect(page).to have_i18n_content(project.title)
    end
  end

  context "when listing proposals in a participatory process" do
    shared_examples_for "a random proposal ordering" do
      let!(:lucky_proposal) { create(:proposal, component:) }
      let!(:unlucky_proposal) { create(:proposal, component:) }
      let!(:lucky_proposal_title) { translated(lucky_proposal.title) }
      let!(:unlucky_proposal_title) { translated(unlucky_proposal.title) }

      it "lists the proposals ordered randomly by default" do
        visit_component

        expect(page).to have_selector("a", text: "Random")
        expect(page).to have_selector(".card--proposal", count: 2)
        expect(page).to have_selector(".card--proposal", text: lucky_proposal_title)
        expect(page).to have_selector(".card--proposal", text: unlucky_proposal_title)
        expect(page).to have_author(lucky_proposal.creator_author.name)
      end
    end

    it_behaves_like "accessible page" do
      before { visit_component }
    end

    it "lists all the proposals" do
      create(:proposal_component,
             manifest:,
             participatory_space: participatory_process)

      create_list(:proposal, 3, component:)

      visit_component
      expect(page).to have_css(".card--proposal", count: 3)
    end

    describe "editable content" do
      it_behaves_like "editable content for admins" do
        let(:target_path) { main_component_path(component) }
      end
    end

    context "when comments have been moderated" do
      let(:proposal) { create(:proposal, component:) }
      let(:author) { create(:user, :confirmed, organization: component.organization) }
      let!(:comments) { create_list(:comment, 3, commentable: proposal) }
      let!(:moderation) { create :moderation, reportable: comments.first, hidden_at: 1.day.ago }

      it "displays unhidden comments count" do
        visit_component

        within("#proposal_#{proposal.id}") do
          within(".card-data__item:last-child") do
            expect(page).to have_content(2)
          end
        end
      end
    end

    describe "default ordering" do
      it_behaves_like "a random proposal ordering"
    end

    context "when voting phase is over" do
      let!(:component) do
        create(:proposal_component,
               :with_votes_blocked,
               manifest:,
               participatory_space: participatory_process)
      end

      let!(:most_voted_proposal) do
        proposal = create(:proposal, component:)
        create_list(:proposal_vote, 3, proposal:)
        proposal
      end
      let!(:most_voted_proposal_title) { translated(most_voted_proposal.title) }

      let!(:less_voted_proposal) { create(:proposal, component:) }
      let!(:less_voted_proposal_title) { translated(less_voted_proposal.title) }

      before { visit_component }

      it "lists the proposals ordered by votes by default" do
        expect(page).to have_selector("a", text: "Most supported")
        expect(page).to have_selector("#proposals .card-grid .column:first-child", text: most_voted_proposal_title)
        expect(page).to have_selector("#proposals .card-grid .column:last-child", text: less_voted_proposal_title)
      end

      it "shows a disabled vote button for each proposal, but no links to full proposals" do
        expect(page).to have_button("Supports disabled", disabled: true, count: 2)
        expect(page).to have_no_link("View proposal")
      end
    end

    context "when voting is disabled" do
      let!(:component) do
        create(:proposal_component,
               :with_votes_disabled,
               manifest:,
               participatory_space: participatory_process)
      end

      describe "order" do
        it_behaves_like "a random proposal ordering"
      end

      it "shows only links to full proposals" do
        create_list(:proposal, 2, component:)

        visit_component

        expect(page).to have_no_button("Supports disabled", disabled: true)
        expect(page).to have_no_button("Vote")
        expect(page).to have_link("View proposal", count: 2)
      end
    end

    context "when there are a lot of proposals" do
      before do
        create_list(:proposal, Decidim::Paginable::OPTIONS.first + 5, component:)
      end

      it "paginates them" do
        visit_component

        expect(page).to have_css(".card--proposal", count: Decidim::Paginable::OPTIONS.first)

        click_link "Next"

        expect(page).to have_selector("[data-pages] [data-page][aria-current='page']", text: "2")

        expect(page).to have_css(".card--proposal", count: 5)
      end
    end

    shared_examples "ordering proposals by selected option" do |selected_option|
      let(:first_proposal_title) { translated(first_proposal.title) }
      let(:last_proposal_title) { translated(last_proposal.title) }
      before do
        visit_component
        within ".order-by" do
          expect(page).to have_selector("ul[data-dropdown-menu$=dropdown-menu]", text: "Random")
          page.find("a", text: "Random").click
          click_link(selected_option)
        end
      end

      it "lists the proposals ordered by selected option" do
        expect(page).to have_selector("#proposals .card-grid .column:first-child", text: first_proposal_title)
        expect(page).to have_selector("#proposals .card-grid .column:last-child", text: last_proposal_title)
      end
    end

    context "when ordering by 'most_voted'" do
      let!(:component) do
        create(:proposal_component,
               :with_votes_enabled,
               manifest:,
               participatory_space: participatory_process)
      end
      let!(:most_voted_proposal) { create(:proposal, component:) }
      let!(:votes) { create_list(:proposal_vote, 3, proposal: most_voted_proposal) }
      let!(:less_voted_proposal) { create(:proposal, component:) }

      it_behaves_like "ordering proposals by selected option", "Most supported" do
        let(:first_proposal) { most_voted_proposal }
        let(:last_proposal) { less_voted_proposal }
      end
    end

    context "when ordering by 'recent'" do
      let!(:older_proposal) { create(:proposal, component:, created_at: 1.month.ago) }
      let!(:recent_proposal) { create(:proposal, component:) }

      it_behaves_like "ordering proposals by selected option", "Recent" do
        let(:first_proposal) { recent_proposal }
        let(:last_proposal) { older_proposal }
      end
    end

    context "when ordering by 'most_followed'" do
      let!(:most_followed_proposal) { create(:proposal, component:) }
      let!(:follows) { create_list(:follow, 3, followable: most_followed_proposal) }
      let!(:less_followed_proposal) { create(:proposal, component:) }

      it_behaves_like "ordering proposals by selected option", "Most followed" do
        let(:first_proposal) { most_followed_proposal }
        let(:last_proposal) { less_followed_proposal }
      end
    end

    context "when ordering by 'most_commented'" do
      let!(:most_commented_proposal) { create(:proposal, component:, created_at: 1.month.ago) }
      let!(:comments) { create_list(:comment, 3, commentable: most_commented_proposal) }
      let!(:less_commented_proposal) { create(:proposal, component:) }

      it_behaves_like "ordering proposals by selected option", "Most commented" do
        let(:first_proposal) { most_commented_proposal }
        let(:last_proposal) { less_commented_proposal }
      end
    end

    context "when ordering by 'most_endorsed'" do
      let!(:most_endorsed_proposal) { create(:proposal, component:, created_at: 1.month.ago) }
      let!(:endorsements) do
        3.times.collect do
          create(:endorsement, resource: most_endorsed_proposal, author: build(:user, organization:))
        end
      end
      let!(:less_endorsed_proposal) { create(:proposal, component:) }

      it_behaves_like "ordering proposals by selected option", "Most endorsed" do
        let(:first_proposal) { most_endorsed_proposal }
        let(:last_proposal) { less_endorsed_proposal }
      end
    end

    context "when ordering by 'with_more_authors'" do
      let!(:most_authored_proposal) { create(:proposal, component:, created_at: 1.month.ago) }
      let!(:coauthorships) { create_list(:coauthorship, 3, coauthorable: most_authored_proposal) }
      let!(:less_authored_proposal) { create(:proposal, component:) }

      it_behaves_like "ordering proposals by selected option", "With more authors" do
        let(:first_proposal) { most_authored_proposal }
        let(:last_proposal) { less_authored_proposal }
      end
    end

    context "when searching proposals" do
      let!(:proposals) do
        [
          create(:proposal, title: "Lorem ipsum dolor sit amet", component:),
          create(:proposal, title: "Donec vitae convallis augue", component:),
          create(:proposal, title: "Pellentesque habitant morbi", component:)
        ]
      end

      before do
        visit_component
      end

      it "finds the correct proposal" do
        within "form.new_filter" do
          find("input[name='filter[search_text_cont]']", match: :first).set("lorem")
          find("*[type=submit]").click
        end

        expect(page).to have_content("Lorem ipsum dolor sit amet")
      end
    end

    context "when paginating" do
      let!(:collection) { create_list :proposal, collection_size, component: }
      let!(:resource_selector) { ".card--proposal" }

      it_behaves_like "a paginated resource"
    end

    context "when component is not commentable" do
      let!(:resources) { create_list(:proposal, 3, component:) }

      it_behaves_like "an uncommentable component"
    end
  end
end
