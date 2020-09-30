# frozen_string_literal: true

require "spec_helper"

describe "Homepage", type: :system do
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
      create :content_block, organization: organization, scope_name: :homepage, manifest_name: :hero
      create :content_block, organization: organization, scope_name: :homepage, manifest_name: :sub_hero
      create :content_block, organization: organization, scope_name: :homepage, manifest_name: :highlighted_content_banner
      create :content_block, organization: organization, scope_name: :homepage, manifest_name: :how_to_participate
      create :content_block, organization: organization, scope_name: :homepage, manifest_name: :stats
      create :content_block, organization: organization, scope_name: :homepage, manifest_name: :metrics
      create :content_block, organization: organization, scope_name: :homepage, manifest_name: :footer_sub_hero

      switch_to_host(organization.host)
    end

    it_behaves_like "editable content for admins" do
      let(:target_path) { visit decidim.root_path }
    end

    context "when requesting the root path" do
      before do
        visit decidim.root_path
      end

      it "includes the official organization links and images" do
        expect(page).to have_selector("a.logo-cityhall[href='#{official_url}']")
        expect(page).to have_selector("a.main-footer__badge[href='#{official_url}']")
      end

      context "and the organization has the omnipresent banner enabled" do
        let(:organization) do
          create(:organization,
                 official_url: official_url,
                 enable_omnipresent_banner: true,
                 omnipresent_banner_url: "#{official_url}/processes",
                 omnipresent_banner_title: Decidim::Faker::Localized.sentence(3),
                 omnipresent_banner_short_description: Decidim::Faker::Localized.sentence(3))
        end

        before do
          switch_to_host(organization.host)
          visit decidim.root_path
        end

        it "shows the omnipresent banner's title" do
          expect(page).to have_i18n_content(organization.omnipresent_banner_title)
        end

        it "shows the omnipresent banner's short description" do
          expect(page).to have_i18n_content(organization.omnipresent_banner_short_description)
        end
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
          expect(page).not_to have_selector("meta[data-hello]", visible: :all)
        end

        context "when header snippets are enabled" do
          before do
            allow(Decidim).to receive(:enable_html_header_snippets).and_return(true)
            visit decidim.root_path
          end

          it "includes the header snippets" do
            expect(page).to have_selector("meta[data-hello]", visible: :all)
          end
        end
      end

      it "welcomes the user" do
        expect(page).to have_content(organization.name)
      end

      context "when there are static pages" do
        let!(:static_page_1) { create(:static_page, organization: organization, show_in_footer: true) }
        let!(:static_page_2) { create(:static_page, organization: organization, show_in_footer: true) }
        let!(:static_page_3) { create(:static_page, organization: organization, show_in_footer: false) }

        before do
          visit current_path
        end

        it "includes links to them" do
          within ".main-footer" do
            [static_page_1, static_page_2].each do |static_page|
              expect(page).to have_content(static_page.title["en"])
            end

            expect(page).to have_no_content(static_page_3.title["en"])
          end

          click_link static_page_1.title["en"]
          expect(page).to have_i18n_content(static_page_1.title)

          expect(page).to have_i18n_content(static_page_1.content)
        end

        it "includes the footer sub_hero with the current organization name" do
          expect(page).to have_css(".footer__subhero")

          within ".footer__subhero" do
            expect(page).to have_content(organization.name)
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

      context "and has highlighted content banner enabled" do
        let(:organization) do
          create(:organization,
                 official_url: official_url,
                 highlighted_content_banner_enabled: true,
                 highlighted_content_banner_title: Decidim::Faker::Localized.sentence(2),
                 highlighted_content_banner_short_description: Decidim::Faker::Localized.sentence(2),
                 highlighted_content_banner_action_title: Decidim::Faker::Localized.sentence(2),
                 highlighted_content_banner_action_subtitle: Decidim::Faker::Localized.sentence(2),
                 highlighted_content_banner_action_url: ::Faker::Internet.url,
                 highlighted_content_banner_image: Decidim::Dev.test_file("city.jpeg", "image/jpeg"))
        end

        before do
          switch_to_host(organization.host)
          visit decidim.root_path
        end

        it "shows the banner's title" do
          expect(page).to have_i18n_content(organization.highlighted_content_banner_title)
        end

        it "shows the banner's description" do
          expect(page).to have_i18n_content(organization.highlighted_content_banner_short_description)
        end

        it "shows the banner's action title" do
          expect(page).to have_i18n_content(organization.highlighted_content_banner_action_title, upcase: true)
        end

        it "shows the banner's action subtitle" do
          expect(page).to have_i18n_content(organization.highlighted_content_banner_action_subtitle)
        end
      end

      context "when downloading open data", download: true do
        before do
          Decidim::OpenDataJob.perform_now(organization)
          switch_to_host(organization.host)
          visit decidim.root_path
        end

        it "lets the users download open data files" do
          click_link "Download Open Data files"
          expect(File.basename(download_path)).to include("open-data.zip")
          Zip::File.open(download_path) do |zipfile|
            expect(zipfile.glob("*open-data-proposals.csv").length).to eq(1)
            expect(zipfile.glob("*open-data-results.csv").length).to eq(1)
            expect(zipfile.glob("*open-data-meetings.csv").length).to eq(1)
          end
        end
      end
    end
  end
end
