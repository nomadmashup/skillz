class User < ActiveRecord::Base

  has_many :skill_details, inverse_of: :user, order: "user_id, skill_id, dimension_id"
  has_many :skills, through: :skill_details, uniq: true, order: "skills.sort_order"
  has_many :dimensions, through: :skill_details, uniq: true, order: "dimensions.sort_order"

  attr_accessible :email, :first_name, :last_name, :project

  # need to load
  #  david.ludwig@hp.com
  #  con.odonnell@hp.com
  #  arjun.patel@hp.com
  #  mike.whitmarsh@hp.com
  #  william.hertling@hp.com
  #  bobt@hp.com
  #  amy.sikora@hp.com
  #  ray.sensenbach@hp.com
  #  brenda.booth@hp.com
  #  fabio.nallem@hp.com
  #  marlon.lopes@hp.com
  #  tales.chaves@hp.com
  #  bill.g.felt@hp.com

  SEED_VALUES = [
    { email: "james.trask@hp.com", first_name: "James", last_name: "Trask", project: "Smart Pubs" },
    { email: "sabrina.kwan@hp.com", first_name: "Sabrina", last_name: "Kwan", project: "Smart Pubs" },
    { email: "kelley.davis@hp.com", first_name: "Kelley", last_name: "Davis", project: "Smart Pubs" },
    { email: "jen.liu@hp.com", first_name: "Jen", last_name: "Liu", project: "Smart Pubs" },
    { email: "peter.dirickson@hp.com", first_name: "Peter", last_name: "Dirickson", project: "Smart Pubs" }
  ]

  def self.seed(overwrite = false)
    SEED_VALUES.each do |item|
      record = find_or_create_by_email item[:email], item
      record.update_attributes! item if overwrite
    end
  end

end