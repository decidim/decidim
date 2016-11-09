require "spec_helper"

module Decidim
  describe "decidim/admin/pages/_form" do
    subject { render }

    let(:form) do
      Decidim::FormBuilder.new(
        :page,
        Decidim::Admin::PageForm.new(slug: slug),
        view,
        {}
      )
    end
    let(:ability) do
      Decidim::Admin::Abilities::AdminUser.new(build(:user, :admin))
    end

    before do
      view.extend CanCan::ControllerAdditions
      allow(view).to receive(:form).and_return(form)
      allow(view).to receive(:current_ability).and_return(ability)
    end

    context "with a default page" do
      let(:slug) { Decidim::Page::DEFAULT_PAGES.sample }
      it { is_expected.to_not include("slug") }
    end

    context "with a normal page" do
      let(:slug) { "foo" }
      it { is_expected.to include("slug") }
    end
  end
end
