# frozen_string_literal: true

require "spec_helper"

describe "Proposals" do
  include ActionView::Helpers::TextHelper
  include_context "with a component"
  let(:manifest_name) { "proposals" }

  let(:root_taxonomy) { create(:taxonomy, organization:) }
  let!(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }
  let!(:user) { create(:user, :confirmed, organization:) }

  let(:address) { "Some address" }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }

  let(:proposal_title) { translated(proposal.title) }

  before do
    stub_geocoding(address, [latitude, longitude])
  end

  matcher :have_author do |name|
    match { |node| node.has_selector?("[data-author]", text: name) }
    match_when_negated { |node| node.has_no_selector?("[data-author]", text: name) }
  end

  matcher :have_creation_date do |date|
    match { |node| node.has_selector?(".author-data__extra", text: date) }
    match_when_negated { |node| node.has_no_selector?(".author-data__extra", text: date) }
  end

  context "when viewing a single proposal" do
    let!(:component) do
      create(:proposal_component,
             manifest:,
             participatory_space: participatory_process)
    end

    let!(:proposals) { create_list(:proposal, 3, component:) }
    let!(:proposal) { proposals.first }

    it_behaves_like "accessible page" do
      before do
        visit_component
        click_on proposal_title
      end
    end

    it "shows the component name in the sidebar" do
      visit_component

      within("aside") do
        expect(page).to have_content(translated(component.name))
      end
    end

    it "allows viewing a single proposal" do
      visit_component

      click_on proposal_title

      expect(page).to have_content(proposal_title)
      expect(page).to have_content(strip_tags(translated(proposal.body)).strip)
      expect(page).to have_author(proposal.creator_author.name)
      expect(page).to have_content(proposal.reference)
      expect(page).to have_content(proposal.published_at.strftime("%d/%m/%Y %H:%M"))
    end

    context "when proposal has a taxonomies" do
      let!(:proposal) { create(:proposal, component:, taxonomies: [taxonomy]) }

      it "can be filtered by taxonomy" do
        visit_component
        click_on proposal_title
        expect(page).to have_content(decidim_sanitize_translated(taxonomy.name))
      end
    end

    context "when it is an official proposal" do
      let(:content) { generate_localized_title }
      let!(:official_proposal) { create(:proposal, :official, body: content, component:) }
      let!(:official_proposal_title) { translated(official_proposal.title) }

      before do
        visit_component
        click_on official_proposal_title
      end

      it "shows the author as official" do
        expect(page).to have_content("Official proposal")
      end

      it_behaves_like "rendering safe content", ".editor-content"
    end

    context "when rich text editor is enabled for participants" do
      let!(:proposal) { create(:proposal, body: content, component:) }

      before do
        organization.update(rich_text_editor_in_public_views: true)
        visit_component
        click_on proposal_title
      end

      it_behaves_like "rendering safe content", ".editor-content"
    end

    context "when rich text editor is NOT enabled for participants" do
      let!(:proposal) { create(:proposal, body: content, component:) }

      before do
        visit_component
        click_on proposal_title
      end

      it_behaves_like "rendering unsafe content", ".editor-content"
    end

    context "when it is an official meeting proposal" do
      include_context "with rich text editor content"
      let!(:proposal) { create(:proposal, :official_meeting, body: content, component:) }

      before do
        visit_component
        click_on proposal_title
      end

      it "shows the author as meeting" do
        expect(page).to have_content(ActionView::Base.full_sanitizer.sanitize(translated(proposal.authors.first.title)))
      end

      it_behaves_like "rendering safe content", ".editor-content"
    end

    context "when a proposal has comments" do
      let(:proposal) { create(:proposal, component:) }
      let(:author) { create(:user, :confirmed, organization: component.organization) }
      let!(:comments) { create_list(:comment, 3, commentable: proposal) }

      it "shows the comments" do
        visit_component
        click_on proposal_title

        comments.each do |comment|
          expect(page).to have_content(comment.body.values.first)
        end
      end
    end

    context "when a proposal has video embeds" do
      let(:cost_report) { { en: "My cost report" } }
      let(:execution_period) { { en: "My execution period" } }
      let(:body) { Decidim::Faker::Localized.localized { "<script>alert(\"TITLE\");</script> #{Faker::Lorem.sentences(number: 3).join("\n")}" } }
      let(:answer) { generate_localized_title }

      let!(:proposal) do
        create(
          :proposal,
          :accepted,
          :official,
          :with_answer,
          component:,
          body:,
          answer:,
          cost: 20_000,
          cost_report:,
          execution_period:
        )
      end

      before do
        component.update!(
          step_settings: {
            component.participatory_space.active_step.id => {
              answers_with_costs: true
            }
          }
        )

        visit_component
        click_on proposal_title
      end

      context "when is created by the admin" do
        context "when the field is body" do
          it_behaves_like "has embedded video in description", :body
        end
      end

      context "when is created by the user" do
        context "when the field is answer" do
          it_behaves_like "has embedded video in description", :answer
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
        click_on proposal_title

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
        click_on proposal_title

        expect(page).to have_i18n_content(decidim_sanitize_translated(meeting.title))
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
        click_on proposal_title

        expect(page).to have_i18n_content(decidim_sanitize_translated(result.title))
      end
    end

    context "when a proposal is in evaluation" do
      let!(:proposal) { create(:proposal, :with_answer, :evaluating, component:) }

      it "shows a badge and an answer" do
        visit_component
        click_on proposal_title

        expect(page).to have_content("Evaluating")

        within ".flash[data-announcement]", style: proposal.proposal_state.css_style do
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
        click_on proposal_title

        expect(page).to have_content("Rejected")

        within ".flash[data-announcement]", style: proposal.proposal_state.css_style do
          expect(page).to have_content("This proposal has been rejected")
          expect(page).to have_i18n_content(proposal.answer)
        end
      end
    end

    context "when a proposal has been accepted" do
      let!(:proposal) { create(:proposal, :with_answer, :accepted, component:) }

      it "shows the acceptance reason" do
        visit_component
        click_on proposal_title

        expect(page).to have_content("Accepted")

        within ".flash[data-announcement]", style: proposal.proposal_state.css_style do
          expect(page).to have_content("This proposal has been accepted")
          expect(page).to have_i18n_content(proposal.answer)
        end
      end
    end

    context "when the proposal answer has not been published" do
      let!(:proposal) { create(:proposal, :accepted_not_published, component:) }

      it "shows the acceptance reason" do
        visit_component
        click_on proposal_title

        within ".layout-author", match: :first do
          expect(page).to have_no_content("Accepted")
        end
        expect(page).to have_no_content("This proposal has been accepted")
        expect(page).not_to have_i18n_content(proposal.answer)
      end
    end

    context "when the proposal's author account has been deleted" do
      let(:proposal) { proposals.first }

      before do
        Decidim::DestroyAccount.call(Decidim::DeleteAccountForm.from_params({}).with_context({ current_user: proposal.creator_author }))
      end

      it "the user is displayed as a deleted user" do
        visit_component

        click_on proposal_title

        expect(page).to have_content("Deleted participant")
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
      click_on proposal_title

      expect(page).to have_i18n_content(decidim_sanitize_translated(project.title))
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

        expect(page).to have_css("a", text: "Random")
        expect(page).to have_css("[id^='proposals__proposal']", count: 2)
        expect(page).to have_css("[id^='proposals__proposal']", text: lucky_proposal_title)
        expect(page).to have_css("[id^='proposals__proposal']", text: unlucky_proposal_title)
        expect(page).to have_author(lucky_proposal.creator_author.name)
      end
    end

    context "when maps are enabled" do
      let(:component) { create(:proposal_component, :with_geocoding_enabled, participatory_space: participatory_process) }

      let!(:author_proposals) { create_list(:proposal, 2, :participant_author, :published, component:) }
      let!(:official_proposals) { create_list(:proposal, 2, :official, :published, component:) }

      # We are providing a list of coordinates to make sure the points are scattered all over the map
      # otherwise, there is a chance that markers can be clustered, which may result in a flaky spec.
      before do
        coordinates = [
          [-95.501705376541395, 95.10059236654689],
          [-95.501705376541395, -95.10059236654689],
          [95.10059236654689, -95.501705376541395],
          [95.10059236654689, 95.10059236654689],
          [142.15275006889419, -33.33377235135252],
          [33.33377235135252, -142.15275006889419],
          [-33.33377235135252, 142.15275006889419],
          [-142.15275006889419, 33.33377235135252],
          [-55.28745034772282, -35.587843900166945]
        ]
        Decidim::Proposals::Proposal.where(component:).geocoded.each_with_index do |proposal, index|
          proposal.update!(latitude: coordinates[index][0], longitude: coordinates[index][1]) if coordinates[index]
        end

        visit_component
      end

      it "shows markers for selected proposals" do
        expect(page).to have_css(".leaflet-marker-icon", count: 4)
        within "#panel-dropdown-menu-origin" do
          click_filter_item "Official"
        end
        expect(page).to have_css(".leaflet-marker-icon", count: 2)

        expect_no_js_errors
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
      expect(page).to have_css("[id^='proposals__proposal']", count: 3)
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
      let!(:moderation) { create(:moderation, reportable: comments.first, hidden_at: 1.day.ago) }

      it "displays unhidden comments count" do
        visit_component

        within("#proposals__proposal_#{proposal.id}") do
          within(".card__list-metadata") do
            expect(page).to have_css("div", text: 2)
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
        expect(page).to have_css("a", text: "Most voted")
        expect(page).to have_css("[id^='proposals__proposal']:first-child", text: most_voted_proposal_title)
        within all("[id^='proposals__proposal']").last do
          expect(page).to have_content(less_voted_proposal_title)
        end
      end
    end

    context "when voting is disabled" do
      let!(:component) do
        create(:proposal_component,
               :with_votes_disabled,
               :with_proposal_limit,
               manifest:,
               participatory_space: participatory_process)
      end

      describe "order" do
        it_behaves_like "a random proposal ordering"
      end

      it "shows only links to full proposals" do
        create_list(:proposal, 2, component:)

        visit_component

        expect(page).to have_css("[id^='proposals__proposal']", count: 2)
      end
    end

    context "when there are a lot of proposals" do
      before do
        create_list(:proposal, Decidim::Paginable::OPTIONS.first + 5, component:)
      end

      it "paginates them" do
        visit_component

        expect(page).to have_css("[id^='proposals__proposal']", count: Decidim::Paginable::OPTIONS.first)

        click_on "Next"

        expect(page).to have_css("[data-pages] [data-page][aria-current='page']", text: "2")

        expect(page).to have_css("[id^='proposals__proposal']", count: 5)
      end
    end

    shared_examples "ordering proposals by selected option" do |selected_option|
      let(:first_proposal_title) { translated(first_proposal.title) }
      let(:last_proposal_title) { translated(last_proposal.title) }
      before do
        visit_component
        within ".order-by" do
          expect(page).to have_css("div.order-by a", text: "Random")
          page.find("a", text: "Random").click
          click_on(selected_option)
        end
      end

      it "lists the proposals ordered by selected option" do
        expect(page).to have_css("[id^='proposals__proposal']:first-child", text: first_proposal_title)
        expect(page).to have_css("[id^='proposals__proposal']:last-child", text: last_proposal_title)
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

      before do
        visit_component
        within ".order-by" do
          expect(page).to have_css("div.order-by a", text: "Random")
          page.find("a", text: "Random").click
          click_on("Most voted")
        end
      end

      it "ordering proposals by selected option", "Most voted" do
        expect(page).to have_css("[id^='proposals__proposal']:first-child", text: translated(most_voted_proposal.title))
        sleep 3
        within all("[id^='proposals__proposal']").last do
          within ".card__list-content" do
            expect(page).to have_css("div.card__list-title", text: translated(less_voted_proposal.title))
          end
        end
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
      let!(:collection) { create_list(:proposal, collection_size, component:) }
      let!(:resource_selector) { "[id^='proposals__proposal']" }

      it_behaves_like "a paginated resource"
    end

    context "when component is not commentable" do
      let!(:resources) { create_list(:proposal, 3, component:) }

      it_behaves_like "an uncommentable component"
    end
  end

  describe "viewing mode for proposals" do
    let!(:proposal) { create(:proposal, :evaluating, component:) }

    context "when participants interact with the proposal view" do
      it "provides an option for toggling between list and grid views" do
        visit_component
        expect(page).to have_css("use[href*='layout-grid-fill']")
        expect(page).to have_css("use[href*='list-check']")
      end
    end

    context "when participants are viewing a grid of proposals" do
      it "shows a grid of proposals with images" do
        visit_component

        # Check that grid view is not the default
        expect(page).to have_no_css(".card__grid-grid")

        # Switch to grid view
        find("a[href*='view_mode=grid']").click
        expect(page).to have_css(".card__grid-grid")
        expect(page).to have_css(".card__grid-img img, .card__grid-img svg")

        # Revisit the component and check session storage
        visit_component
        expect(page).to have_css(".card__grid-grid")
      end
    end

    context "when participants are filtering proposals" do
      let!(:evaluating_proposals) { create_list(:proposal, 3, :evaluating, component:) }
      let!(:accepted_proposals) { create_list(:proposal, 5, :accepted, component:) }

      it "filters the proposals and keeps the filter when changing the view mode" do
        visit_component
        uncheck "Evaluating"

        expect(page).to have_css("[id^='proposals__proposal']", count: 5)

        find("a[href*='view_mode=grid']").click

        expect(page).to have_css(".card__grid-img svg#ri-proposal-placeholder-card-g", count: 5)
        expect(page).to have_css("[id^='proposals__proposal']", count: 5)
      end
    end

    context "when participants are viewing a list of proposals" do
      it "shows a list of proposals" do
        visit_component
        find("a[href*='view_mode=list']").click
        expect(page).to have_css(".card__list-list")
      end
    end

    context "when proposals does not have attachments" do
      it "shows a placeholder image" do
        visit_component
        find("a[href*='view_mode=grid']").click
        expect(page).to have_css(".card__grid-img svg#ri-proposal-placeholder-card-g")
      end
    end

    context "when proposals have attachments" do
      let!(:proposal) { create(:proposal, component:) }
      let!(:attachment) { create(:attachment, attached_to: proposal) }

      before do
        component.update!(settings: { attachments_allowed: true })
      end

      it "shows the proposal image" do
        visit_component

        expect(page).to have_no_css(".card__grid-img img[src*='proposal_image_placeholder.svg']")
        expect(page).to have_css(".card__grid-img img")
      end
    end

    context "when proposal does not have history" do
      let!(:proposal) { create(:proposal, component:) }

      it "shows the proposal with no history panel" do
        visit_component
        click_on proposal_title

        expect(page).to have_no_content("History")
        expect(page).to have_no_content("This proposal was created")
      end
    end

    context "when proposal have history" do
      let!(:proposal) { create(:proposal, component:) }
      let(:budget_component) do
        create(:component, manifest_name: :budgets, participatory_space: proposal.component.participatory_space)
      end
      let(:project) { create(:project, component: budget_component) }

      before do
        project.link_resources([proposal], "included_proposals")
      end

      it "shows the proposal with history panel" do
        visit_component
        click_on proposal_title

        expect(page).to have_content("History")
        expect(page).to have_content("This proposal was created")
      end
    end
  end
end
