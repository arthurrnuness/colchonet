class User < ActiveRecord::Base
	scope :most_recent, -> { order('created_at DESC') }
	scope :from_sampa, -> { where(location: 'São Paulo') }
	scope :from, ->(location) { where(location: location) }

	
	has_many :rooms
	EMAIL_REGEXP = /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/
	scope :confirmed, -> { where.not(confirmed_at: nil) }
	validates_presence_of :email, :full_name, :location
	#validates_confirmation_of :password

	validates_length_of :bio, minimum: 1, allow_blank: false
	validates_uniqueness_of :email

	validate :email_format
	has_secure_password

	before_create do |user|
		user.confirmation_token = SecureRandom.urlsafe_base64
	end

	def self.authenticate(email, password)
		confirmed.find_by(email: email).try(:authenticate, password)		
	end

	def confirm!
		return if confirmed?

		self.confirmed_at = Time.current
		self.confirmation_token = ''
		save!
	end

	def confirmed?
		confirmed_at.present?
	end

	private

	def email_format
		errors.add(:email, :invalid) unless email.match(EMAIL_REGEXP)
	end
end
