# frozen_string_literal: true

 module Decidim
   module Budgets
     module Import
       # This class is responsible for verifying the data for paper ballots import
       class PaperBallotResultVerifier < Decidim::Admin::Import::Verifier
         protected

         def required_headers
           %w(id votes)
         end

         # Check if prepared resource is valid
         #
         # record - Decidim::Budgets::PaperBallotResult
         #
         # Returns true if record is valid
         def valid_record?(record)
           return false if record.nil?
           return false if record.errors.any?

           record.valid?
         end
       end
     end
   end
 end
