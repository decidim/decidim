# frozen_string_literal: true

require "spec_helper"

describe "Homepage", type: :feature do
  context "when there's no organization" do
    before do
      visit decidim.root_path
    end

    it "redirects to system UI and shows a warning" do
      expect(page).to have_current_path(decidim_system.new_admin_session_path)
      expect(page).to have_content("You must create an organization to get started")
    end
  end

  context "when there's an organization" do
    let(:official_url) { "http://mytesturl.me" }
    let(:organization) { create(:organization, official_url: official_url) }

    before do
      switch_to_host(organization.host)
      visit decidim.root_path
    end

    it "includes the official organization links and images" do
      expect(page).to have_selector("a.logo-cityhall[href='#{official_url}']")
      expect(page).to have_selector("a.main-footer__badge[href='#{official_url}']")
    end

    describe "call to action" do
      let!(:participatory_process) { create :participatory_process, :published }
      let!(:organization) { participatory_process.organization }

      before do
        switch_to_host(organization.host)
        visit decidim.root_path
      end

      context "when the organization has the CTA button text customized" do
        let(:cta_button_text) { { en: "Sign up", es: "Regístrate", ca: "Registra't" } }
        let(:organization) { create(:organization, cta_button_text: cta_button_text) }

        before do
          create :static_page, slug: "terms-and-conditions", organization: organization
        end

        it "uses the custom values for the CTA button text" do
          within ".hero" do
            expect(page).to have_selector("a.hero-cta", text: "SIGN UP")
            click_link "Sign up"
          end

          expect(page).to have_current_path decidim.new_user_registration_path
        end
      end

      context "when the organization has the CTA button link customized" do
        let(:organization) { create(:organization, cta_button_path: "users/sign_in") }

        it "uses the custom values for the CTA button" do
          within ".hero" do
            expect(page).to have_selector("a.hero-cta", text: "PARTICIPATE")
            click_link "Participate"
          end

          expect(page).to have_current_path decidim.new_user_session_path
          expect(page).to have_content("Sign in")
          expect(page).to have_content("New to the platform?")
        end
      end

      context "when the organization does not have it customized" do
        it "uses the default values for the CTA button" do
          visit decidim.root_path

          within ".hero" do
            expect(page).to have_selector("a.hero-cta", text: "PARTICIPATE")
            click_link "Participate"
          end

          expect(page).to have_current_path decidim_participatory_processes.participatory_processes_path
        end
      end
    end

    context "with header snippets" do
      let(:snippet) { "<meta data-hello=\"This is the organization header_snippet field\">" }
      let(:organization) { create(:organization, official_url: official_url, header_snippets: snippet) }

      it "does not include the header snippets" do
        expect(page).not_to have_selector("meta[data-hello]", visible: false)
      end

      context "when header snippets are enabled" do
        before do
          allow(Decidim).to receive(:enable_html_header_snippets).and_return(true)
          visit decidim.root_path
        end

        it "includes the header snippets" do
          expect(page).to have_selector("meta[data-hello]", visible: false)
        end
      end
    end

    it "welcomes the user" do
      expect(page).to have_content(organization.name)
    end

    context "when there are static pages" do
      let!(:static_pages) { create_list(:static_page, 3, organization: organization) }

      before do
        visit current_path
      end

      it "includes links to them" do
        within ".main-footer" do
          expect(page).to have_css("ul.footer-nav li a", count: 3)
          static_pages.each do |static_page|
            expect(page).to have_content(static_page.title["en"])
          end
        end

        static_page = static_pages.first
        click_link static_page.title["en"]
        expect(page).to have_i18n_content(static_page.title, locale: "en")

        expect(page).to have_i18n_content(static_page.content, locale: "en")
      end

      it "includes the footer sub_hero with the current organization name" do
        expect(page).to have_css(".footer__subhero")

        within ".footer__subhero" do
          expect(page).to have_content(organization.name)
        end
      end
    end

    describe "includes participatory processes ending soon" do
      context "when there are more than 8 participatory processes" do
        let!(:participatory_process) do
          create_list(
            :participatory_process,
            10,
            :published,
            organization: organization,
            description: { en: "Description", ca: "Descripció", es: "Descripción" },
            short_description: { en: "Short description", ca: "Descripció curta", es: "Descripción corta" }
          )
        end

        it "shows a maximum of 8" do
          visit current_path
          expect(page).to have_selector("article.card", count: 8)
        end
      end

      context "when lists the participatory processes" do
        let!(:participatory_process_1) { create(:participatory_process, :with_steps, promoted: true, organization: organization) }
        let!(:participatory_process_2) { create(:participatory_process, :with_steps, promoted: false, organization: organization) }
        let!(:participatory_process_3) { create(:participatory_process, :with_steps, promoted: true, organization: organization) }

        it "shows promoted first and ordered by active step end_date" do
          processes = [participatory_process_3, participatory_process_1, participatory_process_2]
          participatory_process_1.active_step.update_attributes!(end_date: 5.days.from_now)
          participatory_process_2.active_step.update_attributes!(end_date: 3.days.from_now)
          participatory_process_3.active_step.update_attributes!(end_date: 2.days.from_now)

          visit current_path
          all("article.card .card__title").each_with_index do |node, index|
            expect(node.text).to eq(processes[index].title[I18n.locale.to_s])
          end
        end
      end
    end

    describe "includes statistics" do
      let!(:users) { create_list(:user, 4, :confirmed, organization: organization) }
      let!(:participatory_process) do
        create_list(
          :participatory_process,
          2,
          :published,
          organization: organization,
          description: { en: "Description", ca: "Descripció", es: "Descripción" },
          short_description: { en: "Short description", ca: "Descripció curta", es: "Descripción corta" }
        )
      end

      context "when organization show_statistics attribute is false" do
        let(:organization) { create(:organization, show_statistics: false) }

        it "does not show the statistics block" do
          expect(page).to have_no_content("Current state of #{organization.name}")
        end
      end

      context "when organization show_statistics attribute is true" do
        let(:organization) { create(:organization, show_statistics: true) }

        before do
          visit current_path
        end

        it "shows the statistics block" do
          within "#statistics" do
            expect(page).to have_content("Current state of #{organization.name}")
            expect(page).to have_content("PROCESSES")
            expect(page).to have_content("PARTICIPANTS")
          end
        end

        it "has the correct values for the statistics" do
          within ".users_count" do
            expect(page).to have_content("4")
          end

          within ".processes_count" do
            expect(page).to have_content("2")
          end
        end
      end
    end

    describe "social links" do
      before do
        organization.update(
          twitter_handler: "twitter_handler",
          facebook_handler: "facebook_handler",
          youtube_handler: "youtube_handler",
          github_handler: "github_handler"
        )

        visit current_path
      end

      it "includes the links to social networks" do
        expect(page).to have_xpath("//a[@href = 'https://twitter.com/twitter_handler']")
        expect(page).to have_xpath("//a[@href = 'https://www.facebook.com/facebook_handler']")
        expect(page).to have_xpath("//a[@href = 'https://www.youtube.com/youtube_handler']")
        expect(page).to have_xpath("//a[@href = 'https://www.github.com/github_handler']")
      end
    end
  end
end
