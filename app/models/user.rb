class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name:  Relationship.name , foreign_key: :follower_id, dependent:   :destroy
  has_many :passive_relationships, class_name:  Relationship.name ,foreign_key: :followed_id, dependent:   :destroy
  has_many :following, through: :active_relationships,  source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  before_save   :downcase_email
  
  validates :name,  presence: true, length: { maximum: Settings.user_model.max_name_length }
  validates :email, presence: true, length: { maximum: Settings.user_model.max_email_length },
                    format: { with: VALID_EMAIL_REGEX },uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true


  # Returns a user's status feed.
  def feed
    following_ids = get_following_ids_query
    post = Micropost.arel_table
    Micropost.where(post[:user_id].in(following_ids)
      .or(post[:user_id].eq(id)))
      .includes(:user, image_attachment: :blob).latest
  end

  # Follows a user.
  def follow(other_user)
    following << other_user unless self == other_user
  end

  # Unfollows a user.
  def unfollow(other_user)
    following.delete(other_user)
  end

  # Returns true if the current user is following the other user.
  def following?(other_user)
    following.include?(other_user)
  end

  private

    # Converts email to all lowercase.
    def downcase_email
      self.email = email.downcase
    end

    #query get following id
    def get_following_ids_query
      rela = Relationship.arel_table
      following_ids = rela.project(rela[:followed_id])
        .where(rela[:follower_id].eq(id))
    end
end
