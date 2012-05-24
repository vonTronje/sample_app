FactoryGirl.define do
  factory :user do
    name		"Hagen Mahnke"
    email		"hagen.mahnke@kaeuferportal.de"
    password	"foobar"
    password_confirmation	"foobar"
  end
end