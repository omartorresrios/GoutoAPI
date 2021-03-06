class User < ActiveRecord::Base
  has_secure_password validations: false

  has_many :events, dependent: :destroy

  has_many :send_reviews, class_name: 'Review', foreign_key: 'from', dependent: :nullify
  has_many :received_reviews, class_name: 'Review', foreign_key: 'to', dependent: :nullify

  EMAIL_REGEX = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  FULLNAME_REGEX = /\A[a-zA-Z0-9_-]{3,30}\z/

  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: EMAIL_REGEX }, unless: :google_login?
  # validates :google_id, presence: true, uniqueness: { case_sensitive: false }
  # validates :username, presence: true, uniqueness: { case_sensitive: false }, unless: :google_login?
  validates :fullname, presence: true, unless: :google_login?
  validates :id, presence: true, unless: :google_login?
  # validates :password, presence: true, length: { minimum: 8 }, unless: :google_login?

  attr_accessor :avatar_data

  has_attached_file :avatar, styles: { medium: "300x300>", thumb: "100x100>" }
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\z/

  before_save :decode_avatar_data

  def self.authenticate(email_or_fullname, password)
    user = User.find_by(email: email_or_fullname)
    user && user.authenticate(password)
  end

  def self.authenticate_google(google_id)
    user = User.find_by(google_id: google_id)
    user && user.authenticate(google_id)
  end

  def facebook_login?
    facebook_id.present?
  end

  def google_login?
    google_id.present?
  end

  def decode_avatar_data
    # If avatar_data is present, it means that we were sent an avatar over
    # JSON and it needs to be decoded.  After decoding, the avatar is processed
    # normally via Paperclip.
    if self.avatar_data.present?
      data = StringIO.new(Base64.decode64(self.avatar_data))
      data.class.class_eval {attr_accessor :original_filename, :content_type}
      data.original_filename = self.id.to_s + ".png"
      data.content_type = "image/png"

      self.avatar = data
    end
  end

  def avatar_url
    if facebook_login? && avatar.url.nil?
      "https://graph.facebook.com/#{facebook_id}/picture?type=large"
    else
      avatar.url    
    end
  end
end