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

  unless options.is_a?(Hash) && options[:skip_unpublish_checks]
    context "when the resource is not published" do
      before do
        resource.unpublish!
      end

      it_behaves_like "a 404 page" do
        let(:target_path) { widget_path }
      end
    end
  end

  context "when visiting the embed page for a resource" do
    before do
      visit widget_path
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
          create(:assembly, organization: organization)
        end
        let(:participatory_space) { assembly }

        it "shows the assembly name" do
          expect(page).to have_i18n_content(assembly.title)
        end
      end
    end
  end
end
