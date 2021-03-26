# frozen_string_literal: true

shared_context "with controller rendering the view" do
  # Fix "No route matches" errors with the view.
  before do
    # Needed for the form_for to work (through decidim_form_for)
    # The path shouldn't matter in the controller specs.
    allow(controller.view_context).to receive(:polymorphic_path).and_return("/")

    # Needed for the head and link_to helpers to work
    # The URL shouldn't matter in the controller specs.
    allow(controller.view_context).to receive(:url_for).and_return("/")
  end

  after do
    controller.class_eval { clear_helpers }
  end

  # Rendering of the view is necessary to see the view renders correctly
  # when there are errors on the form. This is hard to test with a
  # system test because there is some JS blocking us to submit the form
  # with errors (e.g. too short title).
  render_views
end
