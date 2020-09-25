# frozen_string_literal: true

require "spec_helper"

describe Decidim::Debates::DebateSearch do
  subject { described_class.new(params).results }

  let(:component) { create :component, manifest_name: "debates" }
  let(:default_params) { { component: component } }
  let(:params) { default_params }

  it_behaves_like "a resource search", :debate
  it_behaves_like "a resource search with categories", :debate
  it_behaves_like "a resource search with origin", :debate

  describe "results" do
    subject { described_class.new(params).results }

    let!(:debate1) do
      create(
        :debate,
        component: component,
        start_time: 1.day.from_now
      )
    end
    let!(:debate2) do
      create(
        :debate,
        component: component,
        start_time: 2.days.from_now
      )
    end

    describe "search_text filter" do
      let(:params) { default_params.merge(search_text: search_text) }
      let(:search_text) { "dog" }

      before do
        debate1.title["en"] = "Do you like my dog?"
        debate1.save
      end

      it "searches the title or the description in i18n" do
        expect(subject).to eq [debate1]
      end
    end
  end
end
