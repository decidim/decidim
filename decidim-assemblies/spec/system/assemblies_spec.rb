# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/has_contextual_help"

describe "Assemblies" do
  let(:organization) { create(:organization) }

  let(:description) { { en: "Description", ca: "Descripció", es: "Descripción" } }
  let(:short_description) { { en: "Short description", ca: "Descripció curta", es: "Descripción corta" } }
  let(:purpose_of_action) { { en: "Purpose of action", ca: "Propòsit de l'acció", es: "Propósito de la acción" } }
  let(:internal_organisation) { { en: "Internal organisation", ca: "Organització interna", es: "Organización interna" } }
  let(:composition) { { en: "Composition", ca: "Composició", es: "Composición" } }
  let(:closing_date_reason) { { en: "Closing date reason", ca: "Motiu de la data de tancament", es: "Razón de la fecha de cierre" } }
  let(:base_assembly) do
    create(
      :assembly,
      :with_content_blocks,
      organization:,
      description:,
      short_description:,
      purpose_of_action:,
      internal_organisation:,
      composition:,
      closing_date_reason:,
      blocks_manifests:
    )
  end
  let(:blocks_manifests) { [] }
  let(:titles) { page.all(".card__grid-text h3") }

  before do
    switch_to_host(organization.host)
  end

  context "when there are no assemblies and directly accessing from URL" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_assemblies.assemblies_path }
    end
  end

  context "when the assembly does not exist" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_assemblies.assembly_path(99_999_999) }
    end
  end

  context "when there are some assemblies and all are unpublished" do
    before do
      create(:assembly, :unpublished, organization:)
      create(:assembly, :published)
    end

    context "and directly accessing from URL" do
      it_behaves_like "a 404 page" do
        let(:target_path) { decidim_assemblies.assemblies_path }
      end
    end
  end

  context "when there are some published assemblies" do
    let!(:assembly) { base_assembly }
    let!(:child_assembly) { create(:assembly, parent: assembly, organization:) }
    let!(:promoted_assembly) { create(:assembly, :promoted, organization:) }
    let!(:unpublished_assembly) { create(:assembly, :unpublished, organization:) }

    it_behaves_like "editable content for admins" do
      let(:target_path) { decidim_assemblies.assemblies_path }
    end

    it_behaves_like "shows contextual help" do
      let(:index_path) { decidim_assemblies.assemblies_path }
      let(:manifest_name) { :assemblies }
    end

    context "and requesting the assemblies path" do
      before do
        visit decidim_assemblies.assemblies_path
      end

      it "lists all the highlighted assemblies" do
        within "#highlighted-assemblies" do
          expect(page).to have_text(translated(promoted_assembly.title, locale: :en))
          expect(page).to have_css("[id^='assembly_highlight']", count: 1)
        end
      end

      it "lists the parent assemblies" do
        within "#assemblies-grid h2" do
          expect(page).to have_text("2")
        end

        expect(page).to have_text(translated(assembly.title, locale: :en))
        expect(page).to have_text(translated(promoted_assembly.title, locale: :en))
        expect(page).to have_css("a.card__grid", count: 2)
        expect(page).to have_css(".card__grid-metadata", text: "1 assembly")
        expect(page).to have_no_text(translated(child_assembly.title, locale: :en))
        expect(page).to have_no_text(translated(unpublished_assembly.title, locale: :en))
      end

      it "links to the individual assembly page" do
        first("a.card__grid", text: translated(assembly.title, locale: :en)).click

        expect(page).to have_current_path decidim_assemblies.assembly_path(assembly)
      end
    end
  end

  it_behaves_like "followable space content for users" do
    let(:assembly) { base_assembly }
    let!(:user) { create(:user, :confirmed, organization:) }
    let(:followable) { assembly }
    let(:followable_path) { decidim_assemblies.assembly_path(assembly) }
  end

  describe "when going to the assembly page" do
    let!(:assembly) { base_assembly }
    let!(:proposals_component) { create(:component, :published, participatory_space: assembly, manifest_name: :proposals) }
    let!(:meetings_component) { create(:component, :unpublished, participatory_space: assembly, manifest_name: :meetings) }

    before do
      create_list(:proposal, 3, component: proposals_component)
      allow(Decidim).to receive(:component_manifests).and_return([proposals_component.manifest, meetings_component.manifest])
    end

    it_behaves_like "editable content for admins" do
      let(:target_path) { decidim_assemblies.assembly_path(assembly) }
    end

    context "and requesting the assembly path with main data and type and duration blocks active" do
      before do
        visit decidim_assemblies.assembly_path(assembly)
      end

      context "when hero, main_data extra_data, metadata and dates_metadata blocks are enabled" do
        let(:blocks_manifests) { [:hero, :main_data, :extra_data, :metadata, :dates_metadata] }

        before do
          visit decidim_assemblies.assembly_path(assembly)
        end

        it "shows the details of the given assembly" do
          within "[data-content]" do
            expect(page).to have_text("About this assembly")
            expect(page).to have_text(translated(assembly.title, locale: :en))
            expect(page).to have_text(translated(assembly.description, locale: :en))
            expect(page).to have_text(translated(assembly.subtitle, locale: :en))
            expect(page).to have_text(translated(assembly.short_description, locale: :en))
            expect(page).to have_text(translated(assembly.meta_scope, locale: :en))
            expect(page).to have_text(translated(assembly.developer_group, locale: :en))
            expect(page).to have_text(translated(assembly.local_area, locale: :en))
            expect(page).to have_text(translated(assembly.target, locale: :en))
            expect(page).to have_text(translated(assembly.participatory_scope, locale: :en))
            expect(page).to have_text(translated(assembly.participatory_structure, locale: :en))
            expect(page).to have_text("DURATION")
            expect(page).to have_text("CLOSING DATE")
            expect(page).to have_text(I18n.l(assembly.duration, format: :decidim_short))
            expect(page).to have_text(I18n.l(assembly.closing_date, format: :decidim_short))
          end
        end

        context "when duration and closing_date are not set" do
          let(:duration) { nil }
          let(:closing_date) { nil }

          before do
            assembly.update(duration:, closing_date:)
            visit decidim_assemblies.assembly_path(assembly)
          end

          it "shows indefinite duration without closing date" do
            within "[data-content]" do
              expect(page).to have_text("DURATION\nIndefinite")
              expect(page).to have_no_text("CLOSING DATE")
            end
          end
        end
      end

      context "when attachments blocks enabled" do
        let(:blocks_manifests) { [:related_documents, :related_images] }

        it_behaves_like "has attachments content blocks" do
          let(:attached_to) { assembly }
        end
      end

      context "when having rich content" do
        let(:blocks_manifests) { [:hero, :main_data, :metadata] }

        context "when short_description" do
          it_behaves_like "has embedded video in description", :short_description
        end

        context "when description" do
          it_behaves_like "has embedded video in description", :description
        end

        context "when purpose_of_action" do
          it_behaves_like "has embedded video in description", :purpose_of_action
        end

        context "when internal_organisation" do
          it_behaves_like "has embedded video in description", :internal_organisation
        end

        context "when composition" do
          it_behaves_like "has embedded video in description", :composition
        end
      end

      context "when the assembly has some components and main data block is active" do
        let(:blocks_manifests) { [:main_data] }

        it "shows the components" do
          within ".participatory-space__nav-container" do
            expect(page).to have_text(translated(proposals_component.name))
            expect(page.html).to include(decidim_escape_translated(proposals_component.name).gsub("&quot;", "\""))
            expect(page).to have_no_text(translated(meetings_component.name))
          end
        end

        describe "when there are special characters (', &) in the nav links" do
          let(:participatory_space) { assembly }
          let(:component_name) { "People's Budget & Ideas" }
          let!(:proposal_component) { create(:proposal_component, name: { en: component_name }, participatory_space:) }

          it "renders the component name correctly" do
            visit current_path
            within ".participatory-space__nav-container" do
              expect(page).to have_text(component_name)
              expect(page).to have_no_text("&#39;")
              expect(page).to have_no_text("&amp;#39;")
            end
          end
        end
      end

      context "and the process statistics are enabled with stats block active" do
        let(:blocks_manifests) { [:stats] }

        it "renders the stats for those components are visible" do
          within "[data-statistic][class*=proposals]" do
            expect(page).to have_css(".statistic__title", text: "Proposals")
            expect(page).to have_css(".statistic__number", text: "3")
            expect(page).to have_no_css(".statistic__title", text: "Meetings")
            expect(page).to have_no_css(".statistic__number", text: "0")
          end
        end
      end

      context "when the assembly has children assemblies and related assemblies block is active" do
        let!(:child_assembly) { create(:assembly, organization:, parent: assembly, weight: 0) }
        let!(:second_child_assembly) { create(:assembly, organization:, parent: assembly, weight: 1) }
        let!(:unpublished_child_assembly) { create(:assembly, :unpublished, organization:, parent: assembly) }
        let(:blocks_manifests) { [:related_assemblies] }

        before do
          visit decidim_assemblies.assembly_path(assembly)
        end

        it "shows only the published children assemblies" do
          within(".participatory-space__block-grid") do
            expect(page).to have_link translated(child_assembly.title)
            expect(page).to have_no_link translated(unpublished_child_assembly.title)
          end
        end

        it "shows the children assemblies by weight" do
          expect(titles.first.text).to eq translated(child_assembly.title)
          expect(titles.last.text).to eq translated(second_child_assembly.title)
        end
      end

      context "when the assembly has children with transparent assemblies and related assemblies block is active" do
        let!(:transparent_child_assembly) { create(:assembly, organization:, parent: assembly, access_mode: :transparent) }
        let!(:transparent_unpublished_child_assembly) { create(:assembly, :unpublished, organization:, parent: assembly, access_mode: :transparent) }
        let(:blocks_manifests) { [:related_assemblies] }

        before do
          visit decidim_assemblies.assembly_path(assembly)
        end

        it "shows only the published and transparent children assemblies" do
          within(".participatory-space__block-grid") do
            expect(page).to have_link translated(transparent_child_assembly.title)
            expect(page).to have_no_link translated(transparent_unpublished_child_assembly.title)
          end
        end
      end

      context "when the assembly has children with restricted assemblies" do
        let!(:child_assembly) { create(:assembly, organization:, parent: assembly, access_mode: :restricted) }
        let!(:unpublished_child_assembly) { create(:assembly, :unpublished, organization:, parent: assembly, access_mode: :restricted) }

        before do
          visit decidim_assemblies.assembly_path(assembly)
        end

        it "not shows any children assemblies" do
          expect(page).to have_no_css(".participatory-space__block-grid")
        end
      end
    end

    context "when the assembly is restricted" do
      let(:blocks_manifests) { [:related_documents, :related_images] }
      let!(:assembly) { create(:assembly, :published, :restricted, :with_content_blocks, blocks_manifests:, organization:) }
      let!(:user) { create(:user, :confirmed, organization:) }
      let!(:member) { create(:member, :published, user:, participatory_space: assembly) }
      let!(:document) { create(:attachment, :with_pdf, attached_to: assembly) }

      before do
        login_as user, scope: :user
        visit decidim_assemblies.assembly_path(assembly, locale: I18n.locale)
      end

      it "shows the document extension in the metadata" do
        expect(all("[data-content] .documents__container").first).to have_css(".card__list-metadata", text: "pdf")
      end
    end
  end

  describe "when going to the assembly child page" do
    let!(:parent_assembly) { base_assembly }
    let!(:child_assembly) { create(:assembly, organization:, parent: parent_assembly) }

    before do
      visit decidim_assemblies.assembly_path(child_assembly)
    end

    it "have a link to the parent assembly" do
      expect(page).to have_link translated(parent_assembly.title)
    end
  end
end
