FactoryGirl.define do  
  factory :user do
    sequence(:name) {|n| "User #{n}" }
  end
  
  factory :artist do
    sequence(:name) {|n| "Artist #{n}" }
  end
  
  factory :song do
    sequence(:name) {|n| "Song #{n}" }
    artist
    association :creator, factory: :user
    association :modifier, factory: :user
  end
  
  factory :comment do
    sequence(:test) {|n| "This is comment #{n}" }
    song
  end
end