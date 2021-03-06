require "uri"

class NoPassword::EmailAuthentication < NoPassword::Model
  attr_accessor :email
  validates :email,
    presence: true,
    format: { with: URI::MailTo::EMAIL_REGEXP }

  def verification
    # We don't want the code in the verification, otherwise
    # the user will set it on the subsequent request, which
    # would undermine the whole thing.
    NoPassword::Verification.new(salt: salt, data: email) if valid?
  end

  def destroy!
    secret.destroy!
  end

  private
    delegate :code, :salt, to: :secret

    def secret
      @secret ||= create_secret
    end

    def create_secret
      NoPassword::Secret.create!(data: email)
    end
end
