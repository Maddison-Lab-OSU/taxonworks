FactoryBot.define do
  
  factory :keyword, traits: [:housekeeping] do
    factory :valid_keyword do
      name { Faker::Lorem.word + Faker::Number.number(5).to_s }
      definition { Faker::Lorem.sentence(10) }
    end
  end

end
