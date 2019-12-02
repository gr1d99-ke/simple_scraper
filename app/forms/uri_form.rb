require "reform/form/validation/unique_validator.rb"

class UriForm < Reform::Form
  properties :name, :host, :user_id
  property :email, virtual: true, populator: :setup_user

  validates :name, presence: true, unique: true
  validates :host, presence: true, host: true

  def setup_user(options)
    email = options[:fragment]

    if email.present?
      user = User.find_or_create_by(email: email)
      self.user_id = user.id
    else
      errors.add(:email, :blank)
    end
  end
end
