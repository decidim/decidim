# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe FilterParamsHelper do
    describe "filter_link_params" do
      subject { helper.filter_link_params(params) }

      let(:params) do
        {
          "order" => "random",
          filter: { "search_text" => "hello" },
          "page" => 2,
          "per_page" => 10,
          "locale" => "en",
          "controller" => "foo",
          "im_a_hacker" => "🤡"
        }
      end

      it { is_expected.to include("filter") }
      it { is_expected.to include("order") }
      it { is_expected.to include("page") }
      it { is_expected.to include("per_page") }
      it { is_expected.to include("locale") }
      it { is_expected.not_to include("controller") }
      it { is_expected.not_to include("im_a_hacker") }

      it "only includes allowed parameters" do
        expect(subject.keys.length).to eq(5)
      end

      context "when no params given" do
        it "gets the params from the controller" do
          expect(helper.controller).to receive(:params).and_return(double(to_unsafe_h: params))
          expect(helper.filter_link_params).not_to be_empty
        end
      end
    end
  end
end
