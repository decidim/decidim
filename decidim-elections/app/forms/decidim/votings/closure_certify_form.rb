# frozen_string_literal: true

module Decidim
  module Votings
    class ClosureCertifyForm < Decidim::Form
      include Decidim::AttachmentAttributes

      attribute :attachment, AttachmentForm
      attachments_attribute :photos

      validates :add_photos, presence: true
      validate :closure_phase

      private

      def closure_phase
        errors.add(:base, :not_in_certificate_phase) unless closure.certificate_phase?
      end

      def closure
        context&.closure || self
      end
    end
  end
end
