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
    let(:meeting) { create(:meeting, :published, component: meeting_component) }
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
          expect(page).to have_css("button#dropdown-documents-trigger-component-#{meeting_component.id}", text: "#{translated(meeting_component.name)} documents")

          click_on "#{translated(meeting_component.name)} documents"

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
          expect(page).to have_no_css("button#dropdown-documents-trigger-component-#{meeting_component.id}", text: "#{translated(meeting_component.name)} documents")
        end
      end
    end

    context "when the component is not published" do
      let(:meeting_component) { create(:meeting_component, :unpublished, participatory_space: attached_to) }

      it "does not show a folder for meeting component" do
        within "[data-content] .documents__container" do
          expect(page).to have_content(translated(document.title))
        end

        within "[data-content]" do
          expect(page).to have_no_css("button#dropdown-documents-trigger-component-#{meeting_component.id}", text: "#{translated(meeting_component.name)} documents")
        end
      end
    end

    context "when the meeting is not published" do
      let(:meeting) { create(:meeting, component: meeting_component) }

      it "does not show a folder for meeting component" do
        within "[data-content] .documents__container" do
          expect(page).to have_content(translated(document.title))
        end

        within "[data-content]" do
          expect(page).to have_no_css("button#dropdown-documents-trigger-component-#{meeting_component.id}", text: "#{translated(meeting_component.name)} documents")
        end
      end
    end
  end

  context "when there is more than one published meeting component" do
    let!(:document) { create(:attachment, :with_pdf, attached_to:, title: { en: "Global document" }) }

    let(:meeting_component) { create(:meeting_component, :published, participatory_space: attached_to, name: { en: "My Meetings" }) }
    let(:meeting) { create(:meeting, :published, component: meeting_component) }
    let!(:meeting_document) { create(:attachment, :with_pdf, attached_to: meeting, title: { en: "My document" }) }

    let(:other_meeting_component) { create(:meeting_component, :published, participatory_space: attached_to, name: { en: "Other Meetings" }) }
    let(:other_meeting) { create(:meeting, :published, component: other_meeting_component) }
    let!(:other_meeting_document) { create(:attachment, :with_pdf, attached_to: other_meeting, title: { en: "Other document" }) }
    let(:extra_meeting) { create(:meeting, :published, component: other_meeting_component, private_meeting:, transparent:) }
    let!(:extra_meeting_document) { create(:attachment, :with_pdf, attached_to: extra_meeting, title: { en: "Extra document" }) }
    let(:private_meeting) { false }
    let(:transparent) { false }

    before do
      visit current_path
    end

    it "shows a folder for each meeting component" do
      within "[data-content] .documents__container" do
        expect(page).to have_content("Global document")
      end

      within "[data-content]" do
        expect(page).to have_css("button#dropdown-documents-trigger-component-#{meeting_component.id}", text: "My Meetings documents")
        expect(page).to have_css("button#dropdown-documents-trigger-component-#{other_meeting_component.id}", text: "Other Meetings documents")

        click_on "My Meetings documents"

        within "#dropdown-menu-documents-component-#{meeting_component.id}" do
          expect(page).to have_content("My document")
          expect(page).to have_no_content("Other document")
          expect(page).to have_no_content("Extra document")
        end

        click_on "Other Meetings documents"

        within "#dropdown-menu-documents-component-#{other_meeting_component.id}" do
          expect(page).to have_no_content("My document")
          expect(page).to have_content("Other document")
          expect(page).to have_content("Extra document")
        end
      end
    end

    context "when one of the meetings has visibility concerns" do
      context "when the meeting private and not transparent" do
        let(:private_meeting) { true }

        it "hides its documents" do
          expect(page).to have_css("button#dropdown-documents-trigger-component-#{meeting_component.id}", text: "My Meetings documents")
          expect(page).to have_css("button#dropdown-documents-trigger-component-#{other_meeting_component.id}", text: "Other Meetings documents")

          click_on "My Meetings documents"

          within "#dropdown-menu-documents-component-#{meeting_component.id}" do
            expect(page).to have_content("My document")
            expect(page).to have_no_content("Other document")
            expect(page).to have_no_content("Extra document")
          end

          click_on "Other Meetings documents"

          within "#dropdown-menu-documents-component-#{other_meeting_component.id}" do
            expect(page).to have_no_content("My document")
            expect(page).to have_content("Other document")
            expect(page).to have_no_content("Extra document")
          end
        end
      end
    end

    context "when the meeting is private and transparent" do
      let(:private_meeting) { true }
      let(:transparent) { true }

      it "shows its documents" do
        expect(page).to have_css("button#dropdown-documents-trigger-component-#{meeting_component.id}", text: "My Meetings documents")
        expect(page).to have_css("button#dropdown-documents-trigger-component-#{other_meeting_component.id}", text: "Other Meetings documents")

        click_on "My Meetings documents"

        within "#dropdown-menu-documents-component-#{meeting_component.id}" do
          expect(page).to have_content("My document")
          expect(page).to have_no_content("Other document")
          expect(page).to have_no_content("Extra document")
        end

        click_on "Other Meetings documents"

        within "#dropdown-menu-documents-component-#{other_meeting_component.id}" do
          expect(page).to have_no_content("My document")
          expect(page).to have_content("Other document")
          expect(page).to have_content("Extra document")
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
