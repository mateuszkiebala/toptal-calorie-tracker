class ApiError
  include ActiveModel::Model

  attr_accessor :status, :title, :detail

  def self.serialize(api_errors)
    return if api_errors.blank?

    data = api_errors.map do |api_error|
      {
        status: api_error.status,
        detail: api_error.detail,
        source: nil,
        title: api_error.title,
        code: nil
      }
    end

    return if data.blank?
    { errors: data }
  end
end
