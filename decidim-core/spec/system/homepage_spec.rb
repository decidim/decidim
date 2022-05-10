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
    let(:organization) do
      create(:organization, official_url: official_url,
                            highlighted_content_banner_enabled: true,
                            highlighted_content_banner_title: Decidim::Faker::Localized.sentence(word_count: 2),
                            highlighted_content_banner_short_description: Decidim::Faker::Localized.sentence(word_count: 2),
                            highlighted_content_banner_action_title: Decidim::Faker::Localized.sentence(word_count: 2),
                            highlighted_content_banner_action_subtitle: Decidim::Faker::Localized.sentence(word_count: 2),
                            highlighted_content_banner_action_url: ::Faker::Internet.url,
                            highlighted_content_banner_image: Decidim::Dev.test_file("city.jpeg", "image/jpeg"))
    end

    before do
      create :content_block, organization: organization, scope_name: :homepage, manifest_name: :hero
      create :content_block, organization: organization, scope_name: :homepage, manifest_name: :sub_hero
      create :content_block, organization: organization, scope_name: :homepage, manifest_name: :highlighted_content_banner
      create :content_block, organization: organization, scope_name: :homepage, manifest_name: :how_to_participate
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

      context "when having homepage anchors" do
        %w(hero sub_hero highlighted_content_banner how_to_participate footer_sub_hero).each do |anchor|
          it { expect(page).to have_selector("##{anchor}", visible: :all) }
        end
      end

      it_behaves_like "accessible page"

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
                 omnipresent_banner_title: Decidim::Faker::Localized.sentence(word_count: 3),
                 omnipresent_banner_short_description: Decidim::Faker::Localized.sentence(word_count: 3))
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
        let!(:static_page1) { create(:static_page, organization: organization, show_in_footer: true) }
        let!(:static_page2) { create(:static_page, organization: organization, show_in_footer: true) }
        let!(:static_page3) { create(:static_page, organization: organization, show_in_footer: false) }

        before do
          visit current_path
        end

        it "includes links to them" do
          within ".main-footer" do
            [static_page1, static_page2].each do |static_page|
              expect(page).to have_content(static_page.title["en"])
            end

            expect(page).to have_no_content(static_page3.title["en"])
          end

          click_link static_page1.title["en"]
          expect(page).to have_i18n_content(static_page1.title)

          expect(page).to have_i18n_content(static_page1.content)
        end

        it "includes the footer sub_hero with the current organization name" do
          expect(page).to have_css(".footer__subhero")

          within ".footer__subhero" do
            expect(page).to have_content(organization.name)
          end
        end

        context "when organization forces users to authenticate before access" do
          let(:organization) do
            create(
              :organization,
              official_url: official_url,
              force_users_to_authenticate_before_access_organization: true
            )
          end
          let(:user) { nil }
          let!(:static_page1) { create(:static_page, organization: organization, show_in_footer: true, allow_public_access: true) }
          let!(:static_page_topic1) { create(:static_page_topic, organization: organization, show_in_footer: true) }
          let!(:static_page_topic1_page1) do
            create(
              :static_page,
              organization: organization,
              topic: static_page_topic1,
              weight: 0,
              allow_public_access: false
            )
          end
          let!(:static_page_topic1_page2) do
            create(
              :static_page,
              organization: organization,
              topic: static_page_topic1,
              weight: 1,
              allow_public_access: true
            )
          end
          let!(:static_page_topic2) { create(:static_page_topic, organization: organization, show_in_footer: true) }
          let!(:static_page_topic2_page1) { create(:static_page, organization: organization, topic: static_page_topic2, weight: 0) }
          let!(:static_page_topic2_page2) { create(:static_page, organization: organization, topic: static_page_topic2, weight: 1) }
          let!(:static_page_topic3) { create(:static_page_topic, organization: organization) }
          let!(:static_page_topic3_page1) { create(:static_page, organization: organization, topic: static_page_topic3) }

          # Re-visit required for the added pages and topics to be visible and
          # to sign in the user when it is defined.
          before do
            login_as user, scope: :user if user
            visit current_path
          end

          it "displays only publicly accessible pages and topics in the footer" do
            within ".main-footer" do
              expect(page).to have_content(static_page1.title["en"])
              expect(page).to have_no_content(static_page2.title["en"])
              expect(page).to have_no_content(static_page3.title["en"])
              expect(page).to have_content(static_page_topic1.title["en"])
              expect(page).to have_no_content(static_page_topic2.title["en"])
              expect(page).to have_no_content(static_page_topic3.title["en"])

              expect(page).to have_link(
                static_page_topic1.title["en"],
                href: "/pages/#{static_page_topic1_page2.slug}"
              )
            end
          end

          context "when authenticated" do
            let(:user) { create :user, :confirmed, organization: organization }

            it_behaves_like "accessible page"

            it "displays all pages and topics in footer that are configured to display in footer" do
              expect(page).to have_content(static_page1.title["en"])
              expect(page).to have_content(static_page2.title["en"])
              expect(page).to have_no_content(static_page3.title["en"])
              expect(page).to have_content(static_page_topic1.title["en"])
              expect(page).to have_content(static_page_topic2.title["en"])
              expect(page).to have_no_content(static_page_topic3.title["en"])

              expect(page).to have_link(
                static_page_topic1.title["en"],
                href: "/pages/#{static_page_topic1_page1.slug}"
              )
              expect(page).to have_link(
                static_page_topic2.title["en"],
                href: "/pages/#{static_page_topic2_page1.slug}"
              )
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

        context "when organization doesn't have the stats content block" do
          let(:organization) { create(:organization) }

          it "does not show the statistics block" do
            expect(page).to have_no_content("Current state of #{organization.name}")
          end
        end

        context "when organization has the stats content block" do
          let(:organization) { create(:organization) }

          before do
            create :content_block, organization: organization, scope_name: :homepage, manifest_name: :stats
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

      describe "includes metrics" do
        context "when organization doesn't have the metrics content block" do
          let(:organization) { create(:organization) }

          it "does not show the statistics block" do
            expect(page).to have_no_content("Participation in figures")
          end
        end

        context "when organization does have the metrics content block" do
          let(:organization) { create(:organization) }
          let(:metrics) do
            Decidim.metrics_registry.all.each do |metric_registry|
              create(:metric, metric_type: metric_registry.metric_name, day: Time.zone.today, organization: organization, cumulative: 5, quantity: 2)
            end
          end

          context "and have metric records" do
            before do
              metrics
              create :content_block, organization: organization, scope_name: :homepage, manifest_name: :metrics
              visit current_path
            end

            it "shows the metrics block" do
              within "#metrics" do
                expect(page).to have_content("Metrics")
                Decidim.metrics_registry.filtered(highlight: true, scope: "home").each do |metric_registry|
                  expect(page).to have_css(%(##{metric_registry.metric_name}_chart), visible: :all)
                end
                Decidim.metrics_registry.filtered(highlight: false, scope: "home").each do |metric_registry|
                  expect(page).to have_css(%(##{metric_registry.metric_name}_chart), visible: :all)
                end
              end
            end
          end

          context "and does not have metric records" do
            before do
              create :content_block, organization: organization, scope_name: :homepage, manifest_name: :metrics
              visit current_path
            end

            it "shows the metrics block empty" do
              within "#metrics" do
                expect(page).to have_content("Metrics")
                Decidim.metrics_registry.highlighted.each do |metric_registry|
                  expect(page).to have_no_css("##{metric_registry.metric_name}_chart")
                end
                Decidim.metrics_registry.not_highlighted.each do |metric_registry|
                  expect(page).to have_no_css("##{metric_registry.metric_name}_chart")
                end
              end
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

      describe "decidim link with external icon" do
        before { visit current_path }

        let(:webpacker_helper) do
          Class.new do
            include ActionView::Helpers::AssetUrlHelper
            include Webpacker::Helper
          end.new
        end

        it "displays the decidim link with external link indicator" do
          within ".footer .mini-footer" do
            expect(page).to have_selector("a[target='_blank'][href='https://github.com/decidim/decidim']")

            within "a[target='_blank'][href='https://github.com/decidim/decidim']" do
              expect(page).to have_selector("svg.icon use[href='#{webpacker_helper.asset_pack_path("media/images/icons.svg")}#icon-external-link']")
            end
          end
        end
      end

      context "and has highlighted content banner enabled" do
        let(:organization) do
          create(:organization,
                 official_url: official_url,
                 highlighted_content_banner_enabled: true,
                 highlighted_content_banner_title: Decidim::Faker::Localized.sentence(word_count: 2),
                 highlighted_content_banner_short_description: Decidim::Faker::Localized.sentence(word_count: 2),
                 highlighted_content_banner_action_title: Decidim::Faker::Localized.sentence(word_count: 2),
                 highlighted_content_banner_action_subtitle: Decidim::Faker::Localized.sentence(word_count: 2),
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
            expect(zipfile.glob("*open-data-elections.csv").length).to eq(1)
            expect(zipfile.glob("*open-data-votings.csv").length).to eq(1)
          end
        end
      end
    end
  end
end
