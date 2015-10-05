class Brand < ActiveRecord::Base
  has_many :tickets

  has_attached_file :logo, :styles => { :medium => '200x200' }

  validates_attachment_content_type :logo, :content_type => ["image/jpeg", "image/png"]
  validates_attachment_size :logo, { :in => 0..2.megabytes }

  scope :available, -> { where(status: true) }
end
