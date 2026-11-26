# frozen_string_literal: true

require "spec_helper"

describe Decidim::PaginateHelper do
  describe "#decidim_paginate" do
    let(:organization) { create(:organization) }
    let(:collection) { Decidim::StaticPage.page(1).per(per_page) }
    let(:item_amount) { per_page + 1 }
    let(:paginate_params) { {} }

    before do
      create_list(:static_page, item_amount, organization:)

      helper.extend(Decidim::UrlHelper)
      allow(helper).to receive(:render).and_return("")
      allow(helper).to receive(:paginate).and_return("")
    end

    context "when per page is supported" do
      let(:per_page) { Decidim::Paginable::OPTIONS.first }

      it "renders the per page options" do
        expect(helper).to receive(:render).with(hash_including(partial: "decidim/shared/results_per_page"))

        helper.decidim_paginate(collection, paginate_params)
      end

      context "with no items" do
        let(:organization) { create(:organization, create_static_pages: false) }
        let(:item_amount) { 0 }

        it "does not render the per page options" do
          expect(helper).not_to receive(:render).with(hash_including(partial: "decidim/shared/results_per_page"))

          helper.decidim_paginate(collection, paginate_params)
        end
      end

      context "when the collection is smaller than smallest per page option" do
        let(:per_page) { Decidim::Paginable::OPTIONS.second }
        let(:item_amount) { 5 }

        it "does not render the per page options" do
          expect(helper).not_to receive(:render).with(hash_including(partial: "decidim/shared/results_per_page"))

          helper.decidim_paginate(collection, paginate_params)
        end
      end

      context "when the collection is larger than smallest per page option" do
        let(:per_page) { Decidim::Paginable::OPTIONS.second }
        let(:item_amount) { Decidim::Paginable::OPTIONS.first + 1 }

        it "renders the per page options" do
          expect(helper).to receive(:render).with(hash_including(partial: "decidim/shared/results_per_page"))

          helper.decidim_paginate(collection, paginate_params)
        end

        context "with per_page param" do
          let(:params) { { per_page: 17 } }

          before do
            allow(helper).to receive(:params).and_return(params)
          end

          it "renders the per page options with correct per_page option" do
            expect(helper).to receive(:render).with(
              hash_including(
                partial: "decidim/shared/results_per_page",
                locals: { per_page: Decidim::Paginable::OPTIONS.first }
              )
            )

            helper.decidim_paginate(collection, paginate_params)
          end
        end

        context "with per_page pagination param" do
          let(:paginate_params) { { per_page: 17 } }

          it "renders the per page options with correct per_page option" do
            expect(helper).to receive(:render).with(
              hash_including(
                partial: "decidim/shared/results_per_page",
                locals: { per_page: Decidim::Paginable::OPTIONS.first }
              )
            )

            helper.decidim_paginate(collection, paginate_params)
          end
        end
      end
    end

    context "when per page is not supported" do
      let(:per_page) { Decidim::Paginable::OPTIONS.first - 1 }

      it "does not render the per page options" do
        expect(helper).not_to receive(:render).with(hash_including(partial: "decidim/shared/results_per_page"))

        helper.decidim_paginate(collection, paginate_params)
      end
    end
  end
end
