# frozen_string_literal: true

require "spec_helper"

shared_examples_for "has attachments content blocks" do
  context "when it has attachments" do
    let!(:document) { create(:attachment, :with_pdf, attached_to:) }

    let!(:image) { create(:attachment, attached_to:) }

    before do
      visit current_path
    end

    it "shows them" do
      within "[data-content] .documents__container" do
        expect(page).to have_content(translated(document.title))
      end

      within "[data-content] [data-gallery]" do
        expect(page).to have_css("img")
      end
    end
  end

  context "when it has meetings components with meetings" do
    let!(:document) { create(:attachment, :with_pdf, attached_to:) }

    let(:meeting_component) { create(:meeting_component, :published, participatory_space: attached_to) }
    let(:meeting) { create(:meeting, component: meeting_component) }
    let!(:meeting_document) { create(:attachment, :with_pdf, attached_to: meeting) }

    before do
      visit current_path
    end

    context "when meetings have attached documents" do
      it "shows a folder for meeting component" do
        within "[data-content] .documents__container" do
          expect(page).to have_content(translated(document.title))
        end

        within "[data-content]" do
          expect(page).to have_css("button#dropdown-documents-trigger-component-#{meeting_component.id}", text: "#{translated(meeting_component.name)} Documents")

          click_on "#{translated(meeting_component.name)} Documents"

          within "#dropdown-menu-documents-component-#{meeting_component.id}" do
            expect(page).to have_content(translated(meeting_document.title))
          end
        end
      end
    end

    context "when meetings have no attached documents" do
      let!(:meeting_document) { nil }

      it "does not show a folder for meeting component" do
        within "[data-content] .documents__container" do
          expect(page).to have_content(translated(document.title))
        end

        within "[data-content]" do
          expect(page).to have_no_css("button#dropdown-documents-trigger-component-#{meeting_component.id}", text: "#{translated(meeting_component.name)} Documents")
        end
      end
    end
  end

  context "when are ordered by weight" do
    let!(:last_document) { create(:attachment, :with_pdf, attached_to:, weight: 2) }
    let!(:first_document) { create(:attachment, :with_pdf, attached_to:, weight: 1) }
    let!(:last_image) { create(:attachment, attached_to:, weight: 2) }
    let!(:first_image) { create(:attachment, attached_to:, weight: 1) }

    before do
      visit current_path
    end

    it "shows them ordered" do
      within "[data-content] .documents__container" do
        expect(decidim_escape_translated(first_document.title).gsub("&quot;", "\"")).to appear_before(decidim_escape_translated(last_document.title).gsub("&quot;", "\""))
      end

      within "[data-content] [data-gallery]" do
        expect(strip_tags(translated(first_image.title, locale: :en))).to appear_before(strip_tags(translated(last_image.title, locale: :en)))
      end
    end
  end
end

shared_examples_for "has attachments tabs" do
  context "when it has attachments" do
    let!(:document) { create(:attachment, :with_pdf, attached_to:) }

    let!(:image) { create(:attachment, attached_to:) }

    before do
      visit current_path
    end

    it "shows them" do
      find("li [data-controls='panel-documents']").click
      within "#panel-documents" do
        expect(page).to have_content(translated(document.title))
      end

      find("li [data-controls='panel-images']").click
      within "#panel-images" do
        expect(page).to have_css("img")
      end
    end
  end

  context "when are ordered by weight" do
    let!(:last_document) { create(:attachment, :with_pdf, attached_to:, weight: 2) }
    let!(:first_document) { create(:attachment, :with_pdf, attached_to:, weight: 1) }
    let!(:last_image) { create(:attachment, attached_to:, weight: 2) }
    let!(:first_image) { create(:attachment, attached_to:, weight: 1) }

    before do
      visit current_path
    end

    it "shows them ordered" do
      find("li [data-controls='panel-documents']").click
      within "#panel-documents" do
        expect(decidim_escape_translated(first_document.title).gsub("&quot;", "\"")).to appear_before(decidim_escape_translated(last_document.title).gsub("&quot;", "\""))
      end

      find("li [data-controls='panel-images']").click
      within "#panel-images" do
        expect(strip_tags(translated(first_image.title, locale: :en))).to appear_before(strip_tags(translated(last_image.title, locale: :en)))
      end
    end
  end
end
