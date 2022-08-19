# frozen_string_literal: true

module Decidim
  module Verifications
    module ApplicationHelper
      def announcement_title(authorization)
        return t("decidim.verifications.id_documents.authorizations.edit.being_reviewed") if authorization.rejected?

        body = content_tag :ul do
          [
            content_tag(:li, t("decidim.verifications.id_documents.authorizations.edit.rejection_correctness")),
            content_tag(:li, t("decidim.verifications.id_documents.authorizations.edit.rejection_clarity"))
          ].join
        end.html_safe

        {
          title: t("decidim.verifications.id_documents.authorizations.edit.rejection_notice"),
          body: body
        }
      end
    end
  end
end
