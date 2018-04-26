# frozen_string_literal: true

module Decidim
  module Proposals
    class CollaborativeDraft < ApplicationRecord
      include Decidim::Resourceable
      include Decidim::Authorable
      include Decidim::HasComponent
      include Decidim::ScopableComponent
      include Decidim::HasReference
      include Decidim::HasCategory
      include Decidim::Reportable
      include Decidim::HasAttachments
      include Decidim::Followable
      include Decidim::Proposals::CommentableCollaborativeDraft
      include Decidim::Traceable
      include Decidim::Loggable

      scope :open, -> { where(state: "open") }
      scope :closed, -> { where(state: "closed") }
      scope :published, -> { where(state: "published") }
    end
  end
end
