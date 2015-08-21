# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

user = User.create(name: 'Tester', email: 'test@example.com', password: 'password', password_confirmation: 'password')

5.times do |i|
  invitation = User.invite!({ email: "test#{i}@example.com", skip_invitation: true }, user)
  User.accept_invitation!(invitation_token: invitation.raw_invitation_token, name: "Tester #{i}", password: 'password', password_confirmation: 'password')
end

5.times do |i|
  User.invite!({ email: "test#{i + 5}@example.com", skip_invitation: true }, user)
end