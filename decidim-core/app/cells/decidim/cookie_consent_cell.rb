# frozen_string_literal: true

module Decidim
  class CookieConsentCell < Decidim::ViewModel
    def show
      render
    end

    def categories
      [
        {
          id: "essential",
          title: "Essential",
          description: "Mauris sed libero. Suspendisse facilisis nulla in lacinia laoreet,
          lorem velit accumsan velit vel mattis libero nisl et sem. Proin interdum maecenas massa
          turpis sagittis in, interdum non lobortis vitae massa. Quisque purus lectus, posuere eget imperdiet nec sodales id arcu.
          Vestibulum elit pede dictum eu, viverra non tincidunt eu ligula.",
          mandatory: true
        },
        {
          id: "preferences",
          title: "Preferences",
          description: "Mauris sed libero. Suspendisse facilisis nulla in lacinia laoreet,
          lorem velit accumsan velit vel mattis libero nisl et sem. Proin interdum maecenas massa
          turpis sagittis in, interdum non lobortis vitae massa. Quisque purus lectus, posuere eget imperdiet nec sodales id arcu.
          Vestibulum elit pede dictum eu, viverra non tincidunt eu ligula."
        },
        {
          id: "analytics",
          title: "Analytics and statistics",
          description: "Mauris sed libero. Suspendisse facilisis nulla in lacinia laoreet,
          lorem velit accumsan velit vel mattis libero nisl et sem. Proin interdum maecenas massa
          turpis sagittis in, interdum non lobortis vitae massa. Quisque purus lectus, posuere eget imperdiet nec sodales id arcu.
          Vestibulum elit pede dictum eu, viverra non tincidunt eu ligula."
        },
        {
          id: "marketing",
          title: "Marketing",
          description: "Mauris sed libero. Suspendisse facilisis nulla in lacinia laoreet,
          lorem velit accumsan velit vel mattis libero nisl et sem. Proin interdum maecenas massa
          turpis sagittis in, interdum non lobortis vitae massa. Quisque purus lectus, posuere eget imperdiet nec sodales id arcu.
          Vestibulum elit pede dictum eu, viverra non tincidunt eu ligula."
        }
      ]
    end
  end
end
