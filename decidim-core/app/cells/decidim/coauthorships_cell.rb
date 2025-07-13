# frozen_string_literal: true

module Decidim
  # This cell renders a collapsible list of a model's coauthors.
  #
  # Example:
  #
  #    cell("decidim/coauthorships", @proposal)
  class CoauthorshipsCell < Decidim::ViewModel
    def show
      if authorable?
        cell "decidim/author", presenter_for_author(model), has_actions: has_actions?, from: model
      else
        cell(
          "decidim/collapsible_authors",
          presenters_for_identities(model),
          options.merge(from: model)
        )
      end
    end

    private

    def official?
      model.respond_to?(:official?) && model.official?
    end

    def presenters_for_identities(coauthorable)
      coauthorable.identities.map do |identity|
        if identity.is_a?(Decidim::Organization)
          "#{model.class.module_parent}::OfficialAuthorPresenter".constantize.new
        else
          present(identity)
        end
      end
    end

    def presenter_for_author(authorable)
      if official?
        "#{model.class.module_parent}::OfficialAuthorPresenter".constantize.new
      else
        authorable.author.presenter
      end
    end

    def authorable?
      model.is_a?(Decidim::Authorable)
    end

    def has_actions?
      options[:has_actions] == true
    end
  end
end
