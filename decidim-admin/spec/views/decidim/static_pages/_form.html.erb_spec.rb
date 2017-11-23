# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe "decidim/admin/static_pages/_form" do
    subject { render }

    let(:form) do
      Decidim::FormBuilder.new(
        :static_page,
        Decidim::Admin::StaticPageForm.new(slug: slug),
        view,
        {}
      )
    end
    let(:ability) do
      Decidim::Admin::Abilities::AdminAbility.new(build(:user, :admin), {})
    end

    before do
      view.extend CanCan::ControllerAdditions
      allow(view).to receive(:form).and_return(form)
      allow(view).to receive(:current_ability).and_return(ability)
    end

    context "with a default static page" do
      let(:slug) { Decidim::StaticPage::DEFAULT_PAGES.sample }

      it { is_expected.not_to include("slug") }
    end

    context "with a normal static page" do
      let(:slug) { "foo" }

      it { is_expected.to include("slug") }
    end
  end
end
