# -*- coding: utf-8 -*-
# frozen_string_literal: true
module Decidim
  # A Helper to render scopes, including a global scope, for forms.
  module OrganizationScopesHelper
    # Public: Returns a collection of the given organization scopes, prepending
    # a global scope. The global scope is at the beginning because it's easier
    # to be found there. Use this helper in places like `select` elements in forms.
    # If you need to show scopes in a search form backed by a `Searchlight::Search`
    # class, see the `search_organization_scopes` helper method.
    #
    # organization - a Decidim::Organiåtion. Uses the helper `current_organization`
    #   by default.
    #
    # Returns an Array.
    def organization_scopes(organization = current_organization)
      [Struct.new(:id, :name).new("", I18n.t("decidim.participatory_processes.scopes.global"))] + organization.scopes
    end

    # Public: Returns a collection of the given organization scopes, prepending
    # a global scope. The global scope is at the beginning because it's easier
    # to be found there. Use this helper in search forms backed by a
    # `Searchlight::Search` class. The reason is, in the `organization_scopes`
    # method we use an empty String as the ID for the Global Scope object, which
    # works fine in normal forms, but Searchlight ignores parameters that are empty
    # Arrays, empty Strings, empty Hashes or nil, so if you want to actively filter
    # those elements that do not have a scope, you cannot send an empty String or
    # nil because Searchlight will ignore the parameter. The only solution here is
    # to use a specific String as ID (`"global"`, in our case), and then treat this
    # case in the search class. This is far from ideal, but I don't know a better
    # way to do this.
    #
    # organization - a Decidim::Organiåtion. Uses the helper `current_organization`
    #   by default.
    #
    # Returns an Array.
    def search_organization_scopes(organization = current_organization)
      [Struct.new(:id, :name).new("global", I18n.t("decidim.participatory_processes.scopes.global"))] + organization.scopes
    end
  end
end
