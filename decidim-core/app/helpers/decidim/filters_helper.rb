# frozen_string_literal: true

module Decidim
  # Helper that provides a single method to create filter resource forms
  module FiltersHelper
    include IconHelper

    # This method wraps everything in a div with class filters and calls
    # the form_for helper with a custom builder
    #
    # filter       - A filter object
    # url          - A String with the URL to post the from. Self URL by default.
    # html_options - Extra HTML options to be passed to form_for
    # block        - A block to be called with the form builder
    #
    # Returns the filter resource form wrapped in a div
    def filter_form_for(filter, url = url_for, html_options = {})
      form_for(
        filter,
        namespace: filter_form_namespace,
        builder: FilterFormBuilder,
        url:,
        as: :filter,
        method: :get,
        remote: true,
        html: { id: nil }.merge(html_options)
      ) do |form|
        inner = []
        inner << hidden_field_tag("per_page", params[:per_page], id: nil) if params[:per_page]
        inner << capture { yield form }
        inner.join.html_safe
      end
    end

    def filter_search_label(label, id)
      label + I18n.t("decidim.searches.filters.resource", collection: filter_for_resource(id))
    end

    def filter_for_resource(skip_to_id)
      case skip_to_id
      when "proposals"
        I18n.t("decidim/proposals/proposal.other", scope: "activerecord.models")
      when "meetings"
        I18n.t("decidim/meetings/meeting.other", scope: "activerecord.models")
      when "debates"
        I18n.t("decidim/debates/debate.other", scope: "activerecord.models")
      when "sortitions"
        I18n.t("decidim/sortitions/sortition.other", scope: "activerecord.models")
      when "surveys"
        I18n.t("decidim/surveys/survey.other", scope: "activerecord.models")
      when "projects"
        I18n.t("decidim/budgets/project.other", scope: "activerecord.models")
      when "initiatives"
        I18n.t("decidim/initiative.other", scope: "activerecord.models")
      else
        ""
      end
    end

    private

    # Creates a unique namespace for a filter form to prevent duplicate IDs in
    # the DOM when multiple filter forms are rendered with the same fields (e.g.
    # for desktop and mobile).
    def filter_form_namespace
      "filters_#{SecureRandom.uuid}"
    end
  end
end
