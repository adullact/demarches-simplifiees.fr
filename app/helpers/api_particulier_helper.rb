module APIParticulierHelper
  def api_particulier_job_exception_reasons(dossier)
    permitted_classes = APIParticulier::Error::HttpError.descendants + [APIParticulier::Entities::Error]

    reasons = dossier.api_particulier_job_exceptions.map do |exception|
      http_error = Psych.safe_load(exception, permitted_classes: permitted_classes)
      http_error.error.reason
    rescue Psych::SyntaxError, Psych::DisallowedClass
      exception.inspect
    end

    simple_format(reasons.join('\n'))
  end
end
