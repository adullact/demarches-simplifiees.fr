# frozen_string_literal: true

module Maintenance
  class T20241120UpdateBlobsServiceNameTask < MaintenanceTasks::Task
    # Documentation : le service ActiveStorage "scaleway" est maintenant renommé en "amazon" (cf. `config/storage.yml`)
    # Les blobs qui référençaient le service "scaleway" doivent donc maintenant utiliser le service "amazon".
    #
    # NB : le stockage des fichiers ne change pas ; seul le service utilisé pour y accéder est différent.

    include RunnableOnDeployConcern
    run_on_first_deploy

    def collection
      ActiveStorage::Blob.where(service_name: "scaleway").in_batches
    end

    def process(blobs_batch)
      blobs_batch.update_all(service_name: "amazon")
    end
  end
end
