class HostValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value.present?

    return if Urls.url_valid?(value)

    record.errors.add(attribute, "is not a valid url")
  end
end
