# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

org = Organisation.create(name: 'Sample Agency', email: 'test@example.com', password: 'password', password_confirmation: 'password')

5.times do |i|
  invitation = Agent.invite!({ email: "test#{i}@example.com", skip_invitation: true }, org)
  invitation.update_attribute(:invitation_sent_at, 10.hours.ago)
  Agent.accept_invitation!(invitation_token: invitation.raw_invitation_token, bank_name: 'Mandiri', insurance_company_name: 'AIA FINANCIAL', first_name: 'First', last_name: 'Last', phone: '+62 21 6539-0605', dob: '27/08/1985', account_name: 'tester account', account_number: '123123123123123', branch_name: 'random bank branch')
end

5.times do |i|
  Agent.invite!({ email: "test#{i + 5}@example.com", skip_invitation: true }, org).update_attribute(:invitation_sent_at, 10.hours.ago)
endAdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password')