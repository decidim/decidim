# frozen_string_literal: true

shared_examples_for "an embed resource" do |options|
  if options.is_a?(Hash) && options[:skip_space_checks]
    let(:organization) { resource.organization }

    before do
      switch_to_host(organization.host)
    end
  else
    include_context "with a component"
  end

  context "when visiting the embed page for a resource" do
    before do
      visit resource_locator(resource).path
      visit "#{current_path}/embed"
    end

    it "renders the page correctly" do
      if resource.title.is_a?(Hash)
        expect(page).to have_i18n_content(resource.title)
      else
        expect(page).to have_content(resource.title)
      end

      expect(page).to have_content(organization.name)
    end

    unless options.is_a?(Hash) && options[:skip_space_checks]
      context "when the participatory_space is a process" do
        it "shows the process name" do
          expect(page).to have_i18n_content(participatory_process.title)
        end
      end

      context "when the participatory_space is an assembly" do
        let(:assembly) do
          create(:assembly, organization:)
        end
        let(:participatory_space) { assembly }

        it "shows the assembly name" do
          expect(page).to have_i18n_content(assembly.title)
        end
      end
    end
  end
end
