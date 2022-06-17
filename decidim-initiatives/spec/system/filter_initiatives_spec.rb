# frozen_string_literal: true

require "spec_helper"

describe "Filter Initiatives", :slow, type: :system do
  let(:organization) { create :organization }
  let(:type1) { create :initiatives_type, organization: }
  let(:type2) { create :initiatives_type, organization: }
  let(:type3) { create :initiatives_type, organization: }
  let(:scoped_type1) { create :initiatives_type_scope, type: type1 }
  let(:scoped_type2) { create :initiatives_type_scope, type: type2 }
  let(:scoped_type3) { create :initiatives_type_scope, type: type3, scope: nil }
  let(:area_type1) { create(:area_type, organization:) }
  let(:area_type2) { create(:area_type, organization:) }
  let(:area1) { create(:area, area_type: area_type1, organization:) }
  let(:area2) { create(:area, area_type: area_type1, organization:) }
  let(:area3) { create(:area, area_type: area_type2, organization:) }

  before do
    switch_to_host(organization.host)
  end

  context "when filtering initiatives by SCOPE" do
    before do
      create_list(:initiative, 2, organization:, scoped_type: scoped_type1)
      create(:initiative, organization:, scoped_type: scoped_type2)
      create(:initiative, organization:, scoped_type: scoped_type3)

      visit decidim_initiatives.initiatives_path
    end

    it "can be filtered by scope" do
      within "form.new_filter" do
        expect(page).to have_content(/Scope/i)
      end
    end

    context "when selecting all scopes" do
      it "lists all initiatives", :slow do
        within ".filters .with_any_scope_check_boxes_tree_filter" do
          check "All"
        end

        expect(page).to have_css(".card--initiative", count: 4)
        expect(page).to have_content("4 INITIATIVES")
      end
    end

    context "when selecting the global scope" do
      it "lists the filtered initiatives", :slow do
        within ".filters .with_any_scope_check_boxes_tree_filter" do
          uncheck "All"
          check "Global"
        end

        expect(page).to have_css(".card--initiative", count: 1)
        expect(page).to have_content("1 INITIATIVE")
      end
    end

    context "when selecting one scope" do
      it "lists the filtered initiatives", :slow do
        within ".filters .with_any_scope_check_boxes_tree_filter" do
          uncheck "All"
          check scoped_type1.scope_name[I18n.locale.to_s]
        end

        expect(page).to have_css(".card--initiative", count: 2)
        expect(page).to have_content("2 INITIATIVES")
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

      visit decidim_initiatives.initiatives_path
    end

    it "can be filtered by state" do
      within "form.new_filter" do
        expect(page).to have_content(/Status/i)
      end
    end

    context "when selecting all states" do
      it "lists all initiatives", :slow do
        within ".filters .with_any_state_check_boxes_tree_filter" do
          uncheck "All"
          check "All"
        end

        expect(page).to have_css(".card--initiative", count: 11)
        expect(page).to have_content("11 INITIATIVES")
      end
    end

    context "when selecting the open state" do
      it "lists the open initiatives", :slow do
        within ".filters .with_any_state_check_boxes_tree_filter" do
          uncheck "All"
          check "Open"
        end

        expect(page).to have_css(".card--initiative", count: 5)
        expect(page).to have_content("5 INITIATIVES")
      end
    end

    context "when selecting the closed state" do
      it "lists the closed initiatives" do
        within ".filters .with_any_state_check_boxes_tree_filter" do
          uncheck "All"
          check "Closed"
        end

        expect(page).to have_css(".card--initiative", count: 6)
        expect(page).to have_content("6 INITIATIVES")
      end
    end

    context "when selecting the accepted state" do
      it "lists the accepted initiatives" do
        within ".filters .with_any_state_check_boxes_tree_filter" do
          uncheck "All"
          within ".filters__has-subfilters" do
            click_button
          end
          check "Enough signatures"
        end

        expect(page).to have_css(".card--initiative", count: 3)
        expect(page).to have_content("3 INITIATIVES")
      end
    end

    context "when selecting the rejected state" do
      it "lists the rejected initiatives" do
        within ".filters .with_any_state_check_boxes_tree_filter" do
          uncheck "All"
          within ".filters__has-subfilters" do
            click_button
          end
          check "Not enough signatures"
        end

        expect(page).to have_css(".card--initiative", count: 2)
        expect(page).to have_content("2 INITIATIVES")
      end
    end

    context "when selecting the answered state" do
      it "lists the answered initiatives" do
        within ".filters .with_any_state_check_boxes_tree_filter" do
          uncheck "All"
          check "Answered"
        end

        expect(page).to have_css(".card--initiative", count: 1)
        expect(page).to have_content("1 INITIATIVE")
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

        visit decidim_initiatives.initiatives_path
      end

      it "doesn't display TYPE filter" do
        expect(page).not_to have_content(/Type/i)
        expect(page).not_to have_css(".filters__section.with_any_type_check_boxes_tree_filter")
      end

      it "lists all initiatives", :slow do
        expect(page).to have_css(".card--initiative", count: 3)
        expect(page).to have_content("3 INITIATIVES")
      end
    end

    context "when there is more than on initiative_type" do
      before do
        create_list(:initiative, 2, organization:, scoped_type: scoped_type1)
        create(:initiative, organization:, scoped_type: scoped_type2)

        visit decidim_initiatives.initiatives_path
      end

      it "can be filtered by type" do
        within "form.new_filter" do
          expect(page).to have_content(/Type/i)
        end
      end

      context "when selecting all types" do
        it "lists all initiatives", :slow do
          within ".filters .with_any_type_check_boxes_tree_filter" do
            check "All"
          end

          expect(page).to have_css(".card--initiative", count: 3)
          expect(page).to have_content("3 INITIATIVES")
        end
      end

      context "when selecting one type" do
        it "lists the filtered initiatives", :slow do
          within ".filters .with_any_type_check_boxes_tree_filter" do
            uncheck "All"
            check type1.title[I18n.locale.to_s]
          end

          expect(page).to have_css(".card--initiative", count: 2)
          expect(page).to have_content("2 INITIATIVES")
        end
      end
    end
  end

  context "when filtering initiatives by AREA" do
    before do
      create_list(:initiative, 2, organization:, area: area1)
      create(:initiative, organization:, area: area2)
      create(:initiative, organization:, area: area3)

      visit decidim_initiatives.initiatives_path
    end

    it "can be filtered by area" do
      within "form.new_filter" do
        expect(page).to have_content(/Area/i)
      end
    end

    context "when selecting all areas" do
      it "lists all initiatives", :slow do
        within ".filters .with_any_area_check_boxes_tree_filter" do
          uncheck "All"
          check "All"
        end

        expect(page).to have_css(".card--initiative", count: 4)
        expect(page).to have_content("4 INITIATIVES")
      end
    end

    context "when selecting one area" do
      it "lists the filtered initiatives", :slow do
        within ".filters .with_any_area_check_boxes_tree_filter" do
          uncheck "All"
          within all(".filters__has-subfilters").first do
            click_button
          end
          within all(".filters__has-subfilters").last do
            click_button
          end
          check area1.name[I18n.locale.to_s]
        end

        expect(page).to have_css(".card--initiative", count: 2)
        expect(page).to have_content("2 INITIATIVES")
      end
    end

    context "when selecting one area type" do
      it "lists the filtered initiatives", :slow do
        within ".filters .with_any_area_check_boxes_tree_filter" do
          uncheck "All"
          check area_type1.name[I18n.locale.to_s]
        end

        expect(page).to have_css(".card--initiative", count: 3)
        expect(page).to have_content("3 INITIATIVES")
      end
    end
  end

  context "when filtering initiatives by AUTHOR" do
    context "when not logged in" do
      before do
        visit decidim_initiatives.initiatives_path
      end

      it "can't be filtered by author" do
        within "form.new_filter" do
          expect(page).not_to have_content(/Author/i)
        end
      end
    end

    context "when logged in" do
      let(:user) { create :user, :confirmed, organization: }

      before do
        create_list(:initiative, 2, organization:, author: user)
        create_list(:initiative, 1, :created, organization:, author: user)
        create(:initiative, organization:)

        login_as user, scope: :user

        visit decidim_initiatives.initiatives_path
      end

      it "can be filtered by author" do
        within "form.new_filter" do
          expect(page).to have_content(/Author/i)
        end
      end

      context "when selecting any author" do
        it "lists all initiatives", :slow do
          within ".filters .author_collection_radio_buttons_filter" do
            choose "Any"
          end

          expect(page).to have_css(".card--initiative", count: 3)
          expect(page).to have_content("3 INITIATIVES")
        end
      end

      context "when selecting my initiatives" do
        it "lists the filtered initiatives", :slow do
          within ".filters .author_collection_radio_buttons_filter" do
            choose "My initiatives"
          end

          expect(page).to have_css(".card--initiative", count: 3)
          expect(page).to have_content("3 INITIATIVES")
        end
      end
    end
  end
end
