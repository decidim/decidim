# frozen_string_literal: true

module Decidim
  # Helper that provides methods to render order selector and links
  module OrdersHelper
    # Public: It renders the order selector for the provided orders
    # (Note) This method requires the javascript 'decidim/orders' to be
    # present in the page.
    #
    # orders - An array of order criteria
    # options - An optional hash of options
    #         * i18n_scope - The scope of the i18n translations
    def order_selector(orders, options = {})
      render partial: "decidim/shared/orders", locals: {
        orders:,
        i18n_scope: options[:i18n_scope],
        css_class: options[:css_class]
      }
    end

    # Public: Returns a resource url merging current params with order
    #
    # order - The name of the order criteria. i.e. 'random'
    # options - An optional hash of options
    #         * i18n_scope - The scope of the i18n translations
    def order_link(order, options = {})
      i18n_scope = options.delete(:i18n_scope)

      link_to(
        t("#{i18n_scope}.#{order}"),
        url_for(params.to_unsafe_h.except(
          "component_id",
          "participatory_process_slug",
          "assembly_slug",
          "initiative_slug"
        ).merge(page: nil, order:)),
        {
          data: { order: },
          remote: true
        }.merge(options)
      )
    end
  end
end
