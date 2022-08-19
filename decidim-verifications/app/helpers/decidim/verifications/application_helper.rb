# frozen_string_literal: true

module Decidim
  module Verifications
    module ApplicationHelper
      def announcement_title(authorization)
        return t("decidim.verifications.id_documents.authorizations.edit.being_reviewed") unless authorization.rejected?

        body = content_tag :ul do
          items = content_tag(:li, t("decidim.verifications.id_documents.authorizations.edit.rejection_correctness"))
          items += content_tag(:li, t("decidim.verifications.id_documents.authorizations.edit.rejection_clarity")).html_safe
          items
        end

        {
          title: t("decidim.verifications.id_documents.authorizations.edit.rejection_notice"),
          body:
        }
      end
    end
  end
end
