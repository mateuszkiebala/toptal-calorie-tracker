class DatetimeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.is_a?(ActiveSupport::TimeWithZone)

    value = value.present? && value.is_a?(String) ? value.gsub(/\A"|"\Z/, '') : nil
    format = "%Y-%m-%dT%H:%M:%S"
    unless (DateTime.strptime(value, format) rescue false)
      record.errors.add(attribute, :invalid_format)
    end
  end
end
