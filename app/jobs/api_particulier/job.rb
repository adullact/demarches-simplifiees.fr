class APIParticulier::Job < ApplicationJob
  DEFAULT_MAX_ATTEMPTS_API_PARTICULIER_JOBS = 5

  queue_as :api_particulier

  # BadGateway could mean
  # - acoss: réessayer ultérieurement
  # - bdf: erreur interne
  # so we retry every day for 5 days
  # same logic for ServiceUnavailable
  rescue_from(APIParticulier::Error::ServiceUnavailable) do |exception|
    retry_or_discard(exception)
  end
  rescue_from(APIParticulier::Error::BadGateway) do |exception|
    retry_or_discard(exception)
  end

  # We guess the backend is slow but not broken
  # and the information we are looking for is available
  # so we retry few seconds later (exponentially to avoid overload)
  retry_on APIParticulier::Error::TimedOut, wait: :exponentially_longer

  # If by the time the job runs the Procedure has been deleted
  discard_on ActiveRecord::RecordNotFound

  rescue_from(APIParticulier::Error::NotFound) do |exception|
    error(self, exception)
  end

  rescue_from(APIParticulier::Error::BadFormatRequest) do |exception|
    error(self, exception)
  end

  def error(job, exception)
    # override ApplicationJob#error to avoid reporting to sentry
  end

  def log_job_exception(exception)
    if etablissement.present?
      if etablissement.dossier.present?
        etablissement.dossier.log_api_entreprise_job_exception(exception)
      elsif etablissement.champ.present?
        etablissement.champ.log_fetch_external_data_exception(exception)
      end
    end
  end

  def retry_or_discard(exception)
    if executions < max_attempts
      retry_job wait: 2.seconds
    else
      log_job_exception(exception)
    end
  end

  def max_attempts
    ENV.fetch("MAX_ATTEMPTS_API_PARTICULIER_JOBS", DEFAULT_MAX_ATTEMPTS_API_PARTICULIER_JOBS).to_i
  end

  attr_reader :procedure

  def find_procedure(procedure_id)
    @procedure = Procedure.find(procedure_id)
  end
end
