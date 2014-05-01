class Order < ActiveRecord::Base
  belongs_to :owner
  belongs_to :organization
  belongs_to :creative
end
