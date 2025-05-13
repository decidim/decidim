# frozen_string_literal: true

require "spec_helper"

describe Decidim::CardMetadataCell, type: :cell do
  subject { cell_html }

  controller Decidim::PagesController

  let!(:model) { create(:dummy_resource) }
  let(:my_cell) { cell("decidim/card_metadata", model, options) }
  let(:options) { {} }
  let(:cell_html) { my_cell.call }

  before do
    allow(model).to receive(:description).and_return(model.body)
  end

  context "when show space is disabled" do
    it "does not render the space the model belongs to" do
      expect(cell_html).to have_no_content(translated_attribute(model.component.participatory_space.title))
    end
  end

  context "when show space is enabled" do
    let(:options) { { show_space: true } }

    it "renders the space the model belongs to" do
      expect(cell_html).to have_content(translated_attribute(model.component.participatory_space.title))
    end
  end

  context "with items enabled" do
    let(:items_list) { [] }
    let(:comments_count) { 0 }
    let(:endorsements_count) { 0 }
    let(:start_date) { nil }
    let(:end_date) { nil }

    before do
      allow(model).to receive(:comments_count).and_return(comments_count)
      allow(model).to receive(:endorsements_count).and_return(endorsements_count)
      allow(my_cell).to receive(:start_date).and_return(start_date)
      allow(my_cell).to receive(:end_date).and_return(end_date)
      my_cell.instance_variable_set(:@items, items_list.map { |name| my_cell.send(name) })
    end

    context "when comments_count enabled" do
      let(:items_list) { [:comments_count_item] }

      context "and comments count is zero" do
        it "displays 0" do
          expect(cell_html).to have_content("0")
        end
      end

      context "and comments count is positive" do
        let(:comments_count) { 123 }

        it "displays the count of comments" do
          expect(cell_html).to have_content("123")
        end
      end
    end

    context "when endorsements_count enabled" do
      let(:items_list) { [:endorsements_count_item] }

      context "and endorsements count is zero" do
        it "displays 0" do
          expect(cell_html).to have_content("0")
        end
      end

      context "and endorsements count is positive" do
        let(:endorsements_count) { 123 }

        it "displays the count of endorsements" do
          expect(cell_html).to have_content("123")
        end
      end
    end

    context "when author_item enabled" do
      let(:items_list) { [:author_item] }

      it "displays the author cell" do
        expect(cell_html).to have_css("p[data-author]")
        expect(cell_html).to have_content(model.author.name)
      end
    end

    context "when progress_item enabled" do
      let(:items_list) { [:progress_item] }

      context "and one of dates is blank" do
        it "displays nothing" do
          expect(cell_html).to have_no_css("span.card__grid-loader")
        end
      end

      context "and both dates are present" do
        let(:start_date) { 4.days.ago.at_beginning_of_day }
        let(:end_date) { 4.days.from_now.at_beginning_of_day }

        it "displays the progress" do
          expect(cell_html).to have_css("span.card__grid-loader")
          expect(cell_html).to have_content(/4 days.*remaining/)
        end
      end
    end

    context "when start_date_item enabled" do
      let(:items_list) { [:start_date_item] }

      context "and one of dates is blank" do
        let(:end_date) { Date.current }

        it "displays nothing" do
          expect(cell_html.text).to be_blank
        end
      end

      context "and both dates are present" do
        let(:start_date) { 4.days.from_now.at_beginning_of_day }
        let(:end_date) { 5.days.from_now.at_beginning_of_day }

        it "displays the duration" do
          expect(cell_html).to have_content("00:00 AM UTC")
        end
      end
    end

    context "when dates_item enabled" do
      let(:items_list) { [:dates_item] }

      context "and one of dates is blank" do
        let(:start_date) { Date.current }

        it "displays nothing" do
          expect(cell_html.text).to be_blank
        end
      end

      context "and both dates are present" do
        let(:current_year) { Date.current.year }

        context "when dates have different year" do
          let(:start_date) { Date.parse("2046-01-31") }
          let(:end_date) { Date.parse("2066-06-06") }

          it "displays the dates including year" do
            expect(cell_html).to have_content("31 Jan 2046 → 06 Jun 2066")
          end
        end

        context "when dates have the current year" do
          let(:start_date) { Date.parse("#{current_year}-01-31") }
          let(:end_date) { Date.parse("#{current_year}-06-06") }

          it "displays the dates excluding year" do
            expect(cell_html).to have_no_content(current_year)
            expect(cell_html).to have_content("31 Jan → 06 Jun")
          end
        end

        context "when dates have the same year but different of current year" do
          let(:start_date) { Date.parse("#{current_year + 5}-01-31") }
          let(:end_date) { Date.parse("#{current_year + 5}-06-06") }

          it "displays the dates including year" do
            expect(cell_html).to have_content("31 Jan #{current_year + 5} → 06 Jun #{current_year + 5}")
          end
        end

        context "when dates are in the same day of current year" do
          let(:start_date) { Time.zone.parse("#{current_year}-01-31 14:30") }
          let(:end_date) { Time.zone.parse("#{current_year}-01-31 17:00") }

          it "displays hour interval excluding year" do
            expect(cell_html).to have_no_content(current_year)
            expect(cell_html).to have_content("31 Jan 14:30 → 17:00")
          end
        end

        context "when dates are in the same day and different year of current" do
          let(:start_date) { Time.zone.parse("#{current_year + 5}-01-31 14:30") }
          let(:end_date) { Time.zone.parse("#{current_year + 5}-01-31 17:00") }

          it "displays hour interval excluding year" do
            expect(cell_html).to have_content("31 Jan #{current_year + 5} 14:30 → 17:00")
          end
        end
      end
    end
  end
end
