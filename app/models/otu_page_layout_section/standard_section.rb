# Standard section definition...
#
class OtuPageLayoutSection::StandardSection < OtuPageLayoutSection

  belongs_to :topic
  validates_presence_of :topic_id

#  def name
#    topic.name
#  end

end
