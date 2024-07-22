# frozen_string_literal: true

require "spec_helper"

describe Decidim::ContentBlocks::ParticipatorySpaceDocumentsCell, type: :cell do
  subject { cell(content_block.cell, content_block).call }

  let(:content_block) do
    create(
      :content_block,
      organization:,
      scope_name: :participatory_process_homepage,
      manifest_name: :related_documents,
      scoped_resource_id: participatory_space.id
    )
  end
  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:participatory_process, organization:) }

  controller Decidim::PagesController

  context "when it has meetings components with attachments" do
    let!(:document) { create(:attachment, :with_pdf, attached_to: participatory_space) }

    let(:meeting_component) { create(:meeting_component, :published, participatory_space:) }
    let(:meeting) { create(:meeting, :published, component: meeting_component) }
    let!(:meeting_document) { create(:attachment, :with_pdf, attached_to: meeting) }

    context "when meetings have attached documents" do
      it "shows a folder for meeting component" do
        expect(subject).to have_css(".documents__container", text: translated(document.title))
        expect(subject).to have_css("button#dropdown-documents-trigger-component-#{meeting_component.id}", text: "Meetings documents")

        section = subject.find("#dropdown-menu-documents-component-#{meeting_component.id}")
        expect(section).to have_content(translated(meeting_document.title))
      end
    end

    context "when meetings have no attached documents" do
      let!(:meeting_document) { nil }

      it "does not show a folder for meeting component" do
        expect(subject).to have_css(".documents__container", text: translated(document.title))
        expect(subject).to have_no_css("button#dropdown-documents-trigger-component-#{meeting_component.id}", text: "Meetings documents")
      end
    end

    context "when the component is not published" do
      let(:meeting_component) { create(:meeting_component, :unpublished, participatory_space:) }

      it "does not show a folder for meeting component" do
        expect(subject).to have_css(".documents__container", text: translated(document.title))
        expect(subject).to have_no_css("button#dropdown-documents-trigger-component-#{meeting_component.id}", text: "Meetings documents")
      end
    end

    context "when the meeting is not published" do
      let(:meeting) { create(:meeting, component: meeting_component) }

      it "does not show a folder for meeting component" do
        expect(subject).to have_css(".documents__container", text: translated(document.title))
        expect(subject).to have_no_css("button#dropdown-documents-trigger-component-#{meeting_component.id}", text: "Meetings documents")
      end
    end
  end

  context "when there is more than one published meeting component" do
    let!(:document) { create(:attachment, :with_pdf, attached_to: participatory_space, title: { en: "Global document" }) }

    let(:meeting_component) { create(:meeting_component, :published, participatory_space:, name: { en: "My Meetings" }) }
    let(:meeting) { create(:meeting, :published, component: meeting_component) }
    let!(:meeting_document) { create(:attachment, :with_pdf, attached_to: meeting, title: { en: "My document" }) }

    let(:other_meeting_component) { create(:meeting_component, :published, participatory_space:, name: { en: "Other Meetings" }) }
    let(:other_meeting) { create(:meeting, :published, component: other_meeting_component) }
    let!(:other_meeting_document) { create(:attachment, :with_pdf, attached_to: other_meeting, title: { en: "Other document" }) }
    let(:extra_meeting) { create(:meeting, :published, component: other_meeting_component, private_meeting:, transparent:) }
    let!(:extra_meeting_document) { create(:attachment, :with_pdf, attached_to: extra_meeting, title: { en: "Extra document" }) }
    let(:private_meeting) { false }
    let(:transparent) { false }

    it "shows a folder for each meeting component" do
      expect(subject).to have_css(".documents__container", text: "Global document")

      expect(subject).to have_css("button#dropdown-documents-trigger-component-#{meeting_component.id}", text: "Meetings documents - My Meetings")
      expect(subject).to have_css("button#dropdown-documents-trigger-component-#{other_meeting_component.id}", text: "Meetings documents - Other Meetings")

      section = subject.find("#dropdown-menu-documents-component-#{meeting_component.id}")
      other_section = subject.find("#dropdown-menu-documents-component-#{other_meeting_component.id}")

      expect(section).to have_content("My document")
      expect(section).to have_no_content("Other document")
      expect(section).to have_no_content("Extra document")

      expect(other_section).to have_no_content("My document")
      expect(other_section).to have_content("Other document")
      expect(other_section).to have_content("Extra document")
    end

    context "when one of the meetings has visibility concerns" do
      context "when the meeting private and not transparent" do
        let(:private_meeting) { true }

        it "hides its documents" do
          expect(subject).to have_css("button#dropdown-documents-trigger-component-#{meeting_component.id}", text: "Meetings documents - My Meetings")
          expect(subject).to have_css("button#dropdown-documents-trigger-component-#{other_meeting_component.id}", text: "Meetings documents - Other Meetings")

          section = subject.find("#dropdown-menu-documents-component-#{meeting_component.id}")
          other_section = subject.find("#dropdown-menu-documents-component-#{other_meeting_component.id}")

          expect(section).to have_content("My document")
          expect(section).to have_no_content("Other document")
          expect(section).to have_no_content("Extra document")

          expect(other_section).to have_no_content("My document")
          expect(other_section).to have_content("Other document")
          expect(other_section).to have_no_content("Extra document")
        end
      end
    end

    context "when the meeting is private and transparent" do
      let(:private_meeting) { true }
      let(:transparent) { true }

      it "shows its documents" do
        expect(subject).to have_css("button#dropdown-documents-trigger-component-#{meeting_component.id}", text: "Meetings documents - My Meetings")
        expect(subject).to have_css("button#dropdown-documents-trigger-component-#{other_meeting_component.id}", text: "Meetings documents - Other Meetings")

        section = subject.find("#dropdown-menu-documents-component-#{meeting_component.id}")
        other_section = subject.find("#dropdown-menu-documents-component-#{other_meeting_component.id}")

        expect(section).to have_content("My document")
        expect(section).to have_no_content("Other document")
        expect(section).to have_no_content("Extra document")

        expect(other_section).to have_no_content("My document")
        expect(other_section).to have_content("Other document")
        expect(other_section).to have_content("Extra document")
      end
    end
  end
end
