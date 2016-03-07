class User
  include Mongoid::BaseModel
  extend OmniauthCallbacks

  paginates_per 10
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  ## Database authenticatable
  field :email,              :type => String, :default => ""
  field :encrypted_password, :type => String, :default => ""

  validates_presence_of :email
  #validates_presence_of :encrypted_password
  
  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  has_many :authorizations
  has_many :feeds
  #has_many :auth_posts, :class_name => "Post", :inverse_of => :author
  has_and_belongs_to_many :edit_posts, :class_name => "Post", :inverse_of => :editors
  has_and_belongs_to_many :collections, :class_name => 'Bullet', :inverse_of => :followers

  # Omniauth authorization
  def self.find_by_email(email)
    where(:email => email).first
  end

  def bind?(provider)
    self.authorizations.collect { |a| a.provider }.include?(provider)
  end

  def bind_service(response)
    provider = response["provider"]
    uid = response["uid"]
    authorizations.create(:provider => provider , :uid => uid )
  end

  ## Token authenticatable
  # field :authentication_token, :type => String
  # run 'rake db:mongoid:create_indexes' to create indexes
  index({ email: 1 }, { unique: true, background: true })

  ## Extra
  field :name
  field :login
  field :location
  field :language
  field :timezone
  field :tagline
  field :is_editor, :type => Boolean, :default => false
  field :is_insider, :type => Boolean, :default => false
  field :order, :type => Integer, :default => 0
  field :avatar
  mount_uploader :avatar, AvatarUploader

  validates_presence_of :name
  attr_accessible :name, :login, :email, :password, :password_confirmation, :remember_me, :created_at, :updated_at,
                  :language, :timezone, :location, :avatar, :is_editor, :is_insider, :order, :authorizations_attributes,
                  :tagline, :sign_in_count, :last_sign_in_at, :current_sign_in_at, :last_sign_in_ip, :current_sign_in_ip


  #=============================================
  #   CanCan
  #=============================================
  def admin?
    Setting.admin_emails.include?(self.email)
  end

  def editor?
    self.admin? or self.is_editor == true
  end

  def has_role?(role)
    case role
      when :admin then admin?
      when :editor then editor?
      else false
    end
  end

  def own_post(post)
    self.admin? or (post.author == self)
  end

end
