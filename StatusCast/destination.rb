class Destination
  attr_accessor :name, :id
  def initialize(id, name)
    @name = name
    @id   = id 
  end

  def self.from_socialcast_groups(groups=[])
    groups.each do |group|
      new(group.id, group.name)
    end
  end
end
