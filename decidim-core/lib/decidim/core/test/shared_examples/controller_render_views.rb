# frozen_string_literal: true

shared_context "with controller rendering the view" do
  # Fix "No route matches" errors with the view.
  before do
    controller.class_eval do
      helper_method :polymorphic_path, :url_for

      # Needed for the form_for to work (through decidim_form_for)
      # The path shouldn't matter in the controller specs.
      def polymorphic_path(_record, _options)
        "/"
      end

      # Needed for the head and link_to helpers to work
      # The URL shouldn't matter in the controller specs.
      def url_for(_options)
        "/"
      end
    end
  end

  # Rendering of the view is necessary to see the view renders correctly
  # when there are errors on the form. This is hard to test with a
  # system test because there is some JS blocking us to submit the form
  # with errors (e.g. too short title).
  render_views
end
