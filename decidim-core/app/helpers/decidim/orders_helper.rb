# frozen_string_literal: true

module Decidim
  # Helper that provides methods to render order selector and links
  module OrdersHelper
    # Public: It renders the order selector for the provided orders
    # (Note) This method requires the javascript 'decidim/orders' to be
    # present in the page.
    #
    # orders - An array of order criterias
    # options - An optional hash of options
    #         * i18n_scope - The scope of the i18n translations
    def order_selector(orders, options = {})
      render partial: "decidim/shared/orders", locals: {
        orders: orders,
        i18n_scope: options[:i18n_scope]
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
        url_for(params.to_unsafe_h.merge(page: nil, order: order)),
        {
          data: { order: order },
          remote: true
        }.merge(options)
      )
    end
  end
end
