class User < ActiveRecord::Base

  attr_reader :password

  validates :username, :password_digest, :session_token, presence: true
  validates :username, :session_token, uniqueness: true
  validates :password, length: { minimum: 6, allow_nil: true }

  has_many :subs, foreign_key: :moderator_id, inverse_of: :moderator
  has_many :posts, foreign_key: :author_id, inverse_of: :author
  has_many :comments, foreign_key: :author_id

  after_initialize :ensure_session_token

  def self.find_by_credentials(username, password)
    user = User.find_by(username: username)
    return nil unless user && user.is_password?(password)
    user
  end

  def password=(password)
    @password = password
    self.password_digest = BCrypt::Password.create(password)
  end

  def is_password?(password)
    BCrypt::Password.new(password_digest).is_password?(password)
  end

  def generate_session_token
    SecureRandom.urlsafe_base64
  end

  def ensure_session_token
    self.session_token ||= generate_session_token
  end

  def reset_session_token!
    self.session_token = generate_session_token
    save!
  end

  private

  def go_away_snowman_hacker
    if self.username.include('☃')
      errors[:username] << "Go away ☃man hacker."
    end
  end


end
