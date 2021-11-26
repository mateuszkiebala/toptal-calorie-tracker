class ApiError
  include ActiveModel::Model

  attr_accessor :source, :details

  def self.serialize(api_errors)
    return if api_errors.blank?

    merged_by_source = {}
    api_errors.map do |api_error|
      merged_by_source[api_error.source] ||= []
      merged_by_source[api_error.source] << api_error
    end

    data = merged_by_source.map do |source, api_errs|
      next if api_errs.blank?

      merged_details = api_errs.map { |ae| ae.details }.flatten
      next if merged_details.blank?

      {
        source: source,
        details: merged_details
      }
    end.compact

    return if data.blank?
    { errors: data }
  end
end
