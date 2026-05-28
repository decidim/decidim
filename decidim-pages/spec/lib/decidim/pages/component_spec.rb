# frozen_string_literal: true

require "spec_helper"

describe "Pages component" do # rubocop:disable RSpec/DescribeClass
  let(:organization) { create(:organization) }
  let(:current_user) { create(:user, :admin, :confirmed, organization:) }
  let(:form_context) do
    {
      current_organization: organization,
      current_user:
    }
  end

  shared_examples "participatory space component duplication" do
    let(:original_component) { create(:page_component, participatory_space:) }
    let!(:original_page) { create(:page, component: original_component) }

    it "copies the page" do
      expect { subject }.to change { Decidim::Pages::Page.where(body: original_page.body).count }.by(1)
    end
  end

  context "with assembly" do
    subject { Decidim::Assemblies::Admin::CopyAssembly.call(form, participatory_space, current_user) }

    let(:form) do
      Decidim::Assemblies::Admin::AssemblyCopyForm.from_params(
        title: { en: "Copied assembly" },
        slug: "copied-assembly",
        copy_components: true
      ).with_context(form_context)
    end
    let(:participatory_space) { create(:assembly, organization:) }

    it_behaves_like "participatory space component duplication"
  end

  context "with conference" do
    subject { Decidim::Conferences::Admin::CopyConference.call(form, participatory_space) }

    let(:form) do
      Decidim::Conferences::Admin::ConferenceCopyForm.from_params(
        title: { en: "Copied conference" },
        slug: "copied-conference",
        copy_components: true
      ).with_context(form_context)
    end
    let(:participatory_space) { create(:conference, organization:) }

    it_behaves_like "participatory space component duplication"
  end

  context "with process" do
    subject { Decidim::ParticipatoryProcesses::Admin::CopyParticipatoryProcess.call(form, participatory_space) }

    let(:form) do
      Decidim::ParticipatoryProcesses::Admin::ParticipatoryProcessCopyForm.from_params(
        title: { en: "Copied process" },
        slug: "copied-process",
        copy_steps: false,
        copy_components: true
      ).with_context(form_context)
    end
    let(:participatory_space) { create(:participatory_process, organization:) }

    it_behaves_like "participatory space component duplication"
  end
end
