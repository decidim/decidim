# frozen_string_literal: true

require "spec_helper"

describe "Filter Initiatives", :slow do
  let!(:organization) { create(:organization) }
  let!(:type1) { create(:initiatives_type, organization:) }
  let!(:type2) { create(:initiatives_type, organization:) }
  let!(:type3) { create(:initiatives_type, organization:) }
  let!(:scoped_type1) { create(:initiatives_type_scope, type: type1) }
  let!(:scoped_type2) { create(:initiatives_type_scope, type: type2) }
  let!(:scoped_type3) { create(:initiatives_type_scope, type: type3, scope: nil) }
  let!(:area_type1) { create(:area_type, organization:) }
  let!(:area_type2) { create(:area_type, organization:) }
  let!(:area1) { create(:area, area_type: area_type1, organization:) }
  let!(:area2) { create(:area, area_type: area_type1, organization:) }
  let!(:area3) { create(:area, area_type: area_type2, organization:) }

  before do
    switch_to_host(organization.host)
  end

  context "when filtering initiatives by SCOPE" do
    let!(:initiatives) { create_list(:initiative, 2, organization:, scoped_type: scoped_type1) }
    let(:first_initiative) { initiatives.first }
    let!(:proposal_comment) { create(:comment, commentable: first_initiative) }

    before do
      create(:initiative, organization:, scoped_type: scoped_type2)
      create(:initiative, organization:, scoped_type: scoped_type3)

      visit decidim_initiatives.initiatives_path(locale: I18n.locale)
    end

    it "can be filtered by scope" do
      within "form.new_filter" do
        expect(page).to have_content(/Scope/i)
      end
    end

    context "when selecting all scopes" do
      it "lists all initiatives", :slow do
        within "#panel-dropdown-menu-scope" do
          click_filter_item "All"
        end

        expect(page).to have_css(".card__grid", count: 4)
        expect(page).to have_content("4 initiatives")
      end
    end

    context "when selecting the global scope" do
      it "lists the filtered initiatives", :slow do
        within "#panel-dropdown-menu-scope" do
          click_filter_item "Global"
        end

        expect(page).to have_css(".card__grid", count: 1)
        expect(page).to have_content("1 initiative")
      end
    end

    context "when selecting one scope" do
      it "lists the filtered initiatives", :slow do
        within "#panel-dropdown-menu-scope" do
          click_filter_item scoped_type1.scope_name[I18n.locale.to_s]
        end

        expect(page).to have_css(".card__grid", count: 2)
        expect(page).to have_content("2 initiatives")
      end

      it "can be ordered by most commented after filtering" do
        within "#panel-dropdown-menu-scope" do
          click_filter_item scoped_type1.scope_name[I18n.locale.to_s]
        end

        within "#dropdown-menu-order" do
          click_on "Most commented"
        end

        expect(page).to have_css(".card__grid[id^='initiative']", count: 2)
        expect(page).to have_css(".card__grid[id^='initiative']:first-child", text: translated(first_initiative.title))
      end
    end
  end

  context "when filtering initiatives by STATE" do
    before do
      create_list(:initiative, 4, organization:)
      create_list(:initiative, 3, :accepted, organization:)
      create_list(:initiative, 2, :rejected, organization:)
      create(:initiative, :acceptable, organization:)
      create(:initiative, organization:, answered_at: Time.current)

      visit decidim_initiatives.initiatives_path(locale: I18n.locale)
    end

    it "can be filtered by state" do
      within "form.new_filter" do
        expect(page).to have_content(/Status/i)
      end
    end

    context "when selecting all states" do
      it "lists all initiatives", :slow do
        stub_const("Decidim::Paginable::OPTIONS", [100])
        within "#panel-dropdown-menu-state" do
          click_filter_item "All"
          click_filter_item "All"
        end

        expect(page).to have_css(".card__grid", count: 11)
        expect(page).to have_content("11 initiatives")
      end
    end

    context "when selecting the open state" do
      it "lists the open initiatives", :slow do
        within "#panel-dropdown-menu-state" do
          click_filter_item "All"
          click_filter_item "Open"
        end

        expect(page).to have_css(".card__grid", count: 5)
        expect(page).to have_content("5 initiatives")
      end
    end

    context "when selecting the closed state" do
      it "lists the closed initiatives" do
        within "#panel-dropdown-menu-state" do
          click_filter_item "Open"
          click_filter_item "Closed"
        end

        expect(page).to have_css(".card__grid", count: 6)
        expect(page).to have_content("6 initiatives")
      end
    end

    context "when selecting the accepted state" do
      it "lists the accepted initiatives" do
        within "#panel-dropdown-menu-state" do
          click_filter_item "Open"
          click_on(id: "dropdown-trigger-with_any_state_state_closed")
          click_filter_item "Enough signatures"
        end

        expect(page).to have_css(".card__grid", count: 3)
        expect(page).to have_content("3 initiatives")
      end
    end

    context "when selecting the rejected state" do
      it "lists the rejected initiatives" do
        within "#panel-dropdown-menu-state" do
          click_filter_item "Open"
          click_on(id: "dropdown-trigger-with_any_state_state_closed")
          click_filter_item "Not enough signatures"
        end

        expect(page).to have_css(".card__grid", count: 2)
        expect(page).to have_content("2 initiatives")
      end
    end

    context "when selecting the answered state" do
      it "lists the answered initiatives" do
        within "#panel-dropdown-menu-state" do
          click_filter_item "Open"
          click_filter_item "Answered"
        end

        expect(page).to have_css(".card__grid", count: 1)
        expect(page).to have_content("1 initiative")
      end
    end
  end

  context "when filtering initiatives by TYPE" do
    context "when there is a single initiative_type" do
      let(:type2) { nil }
      let(:type3) { nil }
      let(:scoped_type2) { nil }
      let(:scoped_type3) { nil }

      before do
        create_list(:initiative, 3, organization:, scoped_type: scoped_type1)

        visit decidim_initiatives.initiatives_path(locale: I18n.locale)
      end

      it "does not display TYPE filter" do
        expect(page).to have_no_css("#panel-dropdown-menu-type")
      end

      it "lists all initiatives", :slow do
        expect(page).to have_css(".card__grid", count: 3)
        expect(page).to have_content("3 initiatives")
      end
    end

    context "when there is more than one initiative_type" do
      before do
        create_list(:initiative, 2, organization:, scoped_type: scoped_type1)
        create(:initiative, organization:, scoped_type: scoped_type2)

        visit decidim_initiatives.initiatives_path(locale: I18n.locale)
      end

      it "can be filtered by type" do
        within "form.new_filter" do
          expect(page).to have_content(/Type/i)
        end
      end

      context "when selecting all types" do
        it "lists all initiatives", :slow do
          within "#panel-dropdown-menu-type" do
            click_filter_item "All"
          end

          expect(page).to have_css(".card__grid", count: 3)
          expect(page).to have_content("3 initiatives")
        end
      end

      context "when selecting one type" do
        it "lists the filtered initiatives", :slow do
          within "#panel-dropdown-menu-type" do
            click_filter_item type1.title[I18n.locale.to_s]
          end

          expect(page).to have_css(".card__grid", count: 2)
          expect(page).to have_content("2 initiatives")
        end
      end
    end
  end

  context "when filtering initiatives by AREA" do
    before do
      create_list(:initiative, 2, organization:, area: area1)
      create(:initiative, organization:, area: area2)
      create(:initiative, organization:, area: area3)

      visit decidim_initiatives.initiatives_path(locale: I18n.locale)
    end

    it "can be filtered by area" do
      within "form.new_filter" do
        expect(page).to have_content(/Area/i)
      end
    end

    context "when selecting all areas" do
      it "lists all initiatives", :slow do
        within "#panel-dropdown-menu-area" do
          click_filter_item "All"
          click_filter_item "All"
        end

        expect(page).to have_css(".card__grid", count: 4)
        expect(page).to have_content("4 initiatives")
      end
    end

    context "when selecting one area" do
      it "lists the filtered initiatives", :slow do
        within "#panel-dropdown-menu-area" do
          within ".filter", text: area_type1.name[I18n.locale.to_s] do
            find("button[aria-expanded='false']").click
          end
          within ".filter", text: area_type2.name[I18n.locale.to_s] do
            find("button[aria-expanded='false']").click
          end
          click_filter_item area1.name[I18n.locale.to_s]
        end

        expect(page).to have_css(".card__grid", count: 2)
        expect(page).to have_content("2 initiatives")
      end
    end

    context "when selecting one area type" do
      it "lists the filtered initiatives", :slow do
        within "#panel-dropdown-menu-area" do
          click_filter_item area_type1.name[I18n.locale.to_s]
        end

        expect(page).to have_css(".card__grid", count: 3)
        expect(page).to have_content("3 initiatives")
      end
    end
  end
end
