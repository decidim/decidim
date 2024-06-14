# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/meta_image_url_examples"

describe "Show a Proposal" do
  include_context "with a component"
  let(:manifest_name) { "proposals" }
  let(:proposal) { create(:proposal, component:) }

  def visit_proposal
    visit resource_locator(proposal).path
  end

  def meta_image_url
    find('meta[property="og:image"]', visible: false)[:content]
  rescue Capybara::ElementNotFound
    nil
  end

  describe "proposal show" do
    it_behaves_like "editable content for admins" do
      let(:target_path) { resource_locator(proposal).path }
    end

    context "when requesting the proposal path" do
      before do
        visit_proposal
        expect(page).to have_content(translated(proposal.title))
      end

      it_behaves_like "share link"

      describe "extra admin link" do
        before do
          login_as user, scope: :user
          visit current_path
        end

        context "when I am an admin user" do
          let(:user) { create(:user, :admin, :confirmed, organization:) }

          it "has a link to answer to the proposal at the admin" do
            within "header" do
              expect(page).to have_css("#admin-bar")
              expect(page).to have_link("Answer", href: /.*admin.*proposal-answer.*/)
            end
          end
        end

        context "when I am a regular user" do
          let(:user) { create(:user, :confirmed, organization:) }

          it "does not have a link to answer the proposal at the admin" do
            within "header" do
              expect(page).to have_no_css("#admin-bar")
              expect(page).to have_no_link("Answer")
            end
          end
        end
      end

      describe "author tooltip" do
        let(:user) { create(:user, :confirmed, organization:) }

        before do
          login_as user, scope: :user
          visit current_path
        end

        context "when author does not restrict messaging" do
          it "includes a link to message the proposal author" do
            within "[data-author]" do
              find(".author__container").hover
            end
            expect(page).to have_link("Send private message")
          end
        end
      end
    end

    describe "testing image hierarchy for meta tags" do
      let(:organization) { create(:organization) }
      let(:manifest_name) { "proposals" }
      let!(:participatory_process) { create(:participatory_process, :with_steps, organization:, banner_image:, hero_image:) }
      let(:banner_image) { nil }
      let(:hero_image) { nil }

      let!(:component) do
        create(:proposal_component,
               :with_creation_enabled,
               :with_attachments_allowed,
               participatory_space: participatory_process)
      end

      let!(:proposal) do
        create(:proposal,
               :official,
               component:,
               title: "Proposal with attachments",
               body: { en: "This is my proposal and I want to upload attachments. <p><img src=\"#{description_image_path}\"></p>" })
      end

      context "when the proposal has an attachment" do
        let!(:proposal_attachment) { create(:attachment, :with_image, attached_to: proposal, file: proposal_attachment_file) }
        let!(:proposal_attachment_file) { Decidim::Dev.test_file("city2.jpeg", "image/jpeg") }

        it_behaves_like "meta image url examples", "city2.jpeg" do
          let(:resource) { proposal }
        end
      end

      context "when proposal attachment is not present and the description image is there" do
        it_behaves_like "meta image url examples", "description_image.jpg" do
          let(:resource) { proposal }
        end
      end

      context "when neither proposal attachment nor description image is present" do
        let!(:participatory_space_attachment) { create(:attachment, :with_image, attached_to: participatory_process, file: hero_image) }
        let(:hero_image) { Decidim::Dev.test_file("city3.jpeg", "image/jpeg") }

        before do
          proposal.update!(body: { en: "This is my proposal and I want to upload attachments." })
        end

        it_behaves_like "meta image url examples", "city3.jpeg" do
          let(:resource) { proposal }
        end
      end

      context "when no images are present" do
        before do
          Decidim::Admin::ContentBlocks::UpdateContentBlock.new(form, content_block, :homepage).call
          proposal.update!(body: { en: "This is my proposal" })
        end

        it_behaves_like "meta image url examples", "default_hero_image.jpg" do
          let(:resource) { proposal }
        end
      end
    end
  end
end
