# frozen_string_literal: true

require "spec_helper"

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

    context "when testing image hierarchy for meta tags" do
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

      let(:description_image) do
        ActiveStorage::Blob.create_and_upload!(
          io: File.open(Decidim::Dev.asset("city3.jpeg")),
          filename: "description_image.jpg",
          content_type: "image/jpeg"
        )
      end

      let(:description_image_path) { Rails.application.routes.url_helpers.rails_blob_path(description_image, only_path: true) }

      let!(:content_block) { create(:content_block, organization:, manifest_name: :hero, scope_name: :homepage) }

      context "when the proposal has an attachment" do
        let!(:proposal_attachment) { create(:attachment, :with_image, attached_to: proposal, file: proposal_attachment_file) }
        let!(:proposal_attachment_file) { Decidim::Dev.test_file("city2.jpeg", "image/jpeg") }

        it "uses the attachment image if present" do
          visit_proposal
          expect(meta_image_url).to include(proposal_attachment.file.filename.to_s)
        end
      end

      context "when proposal attachment is not present and the description image is there" do
        it "uses the description image if present" do
          visit_proposal
          expect(meta_image_url).to include(description_image.filename.to_s)
        end
      end

      context "when neither proposal attachment nor description image is present" do
        let(:file) { Decidim::Dev.test_file("city3.jpeg", "image/jpeg") }
        let!(:participatory_space_attachment) { create(:attachment, :with_image, attached_to: participatory_process, file:) }
        let(:hero_image) { Decidim::Dev.test_file("city3.jpeg", "image/jpeg") }

        before do
          proposal.update!(body: { en: "This is my proposal and I want to upload attachments." })
        end

        it "uses the participatory space image if no attachment or description image" do
          visit_proposal
          expect(meta_image_url).to include(participatory_space_attachment.file.filename.to_s)
        end
      end

      context "when no images are present" do
        let(:uploaded_image) do
          ActiveStorage::Blob.create_and_upload!(
            io: File.open(Decidim::Dev.asset("city2.jpeg")),
            filename: "city2.jpeg",
            content_type: "image/jpeg"
          )
        end

        let(:images) do
          {
            "background_image" => uploaded_image.signed_id
          }
        end

        let(:form_klass) { Decidim::Admin::ContentBlockForm }
        let(:form) { form_klass.from_params(content_block: { images: }) }

        before do
          Decidim::Admin::ContentBlocks::UpdateContentBlock.new(form, content_block, :homepage).call
          proposal.update!(body: { en: "This is my proposal" })
        end

        it "uses the default image if no other images are present" do
          visit_proposal
          expect(meta_image_url).to include("city2.jpeg")
        end
      end
    end
  end
end
