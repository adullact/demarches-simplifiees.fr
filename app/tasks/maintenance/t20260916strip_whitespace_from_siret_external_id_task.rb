# frozen_string_literal: true

module Maintenance
  class T20260916stripWhitespaceFromSiretExternalIdTask < MaintenanceTasks::Task
    # `normalizes :external_id` strips whitespace on assignment, but
    # T20251029backfillChampSiretExternalStateTask filled the column with
    # Arel.sql('champs.value'), a raw expression Rails never casts: the champs it
    # moved still hold the siret with the spaces the user typed. Those build a
    # malformed API Entreprise URL that curl refuses before any call goes out.
    #
    # Batching over every siret champ rather than over the dirty ones alone: on a
    # table this size a rare predicate makes each batch scan until it has found
    # BATCH_SIZE matches, which the 60s statement_timeout cuts short. Here a batch
    # stops after BATCH_SIZE rows and the UPDATE filters what it writes.
    #
    # One UPDATE per batch, no record instantiated: neither the champ nor its
    # dossier is dated, so nothing moves up the instructeur list.

    BATCH_SIZE = 1_000

    def collection
      Champs::SiretChamp.in_batches(of: BATCH_SIZE)
    end

    def process(batch)
      batch
        .where("external_id ~ '[[:space:]]'")
        .update_all("external_id = regexp_replace(external_id, '[[:space:]]', '', 'g')")
    end

    def count
      # a COUNT over champs triggers a PG statement timeout
    end
  end
end
