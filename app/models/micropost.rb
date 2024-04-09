class Micropost < ApplicationRecord
  belongs_to       :user

  has_one_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: [500, 500]
  end
  scope :ordered_by_created_at_desc -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :image,   content_type: { in: Settings.content_types.image,message: errors.messages.invalid_image_format},size: { less_than: 5.megabytes, message: errors.messages.image_too_large }
end