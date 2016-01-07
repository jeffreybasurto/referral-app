namespace :devise do
  desc 'Mass agent password reset and send email instructions'
  task :mass_password_reset => :environment do
    begin
      Agent.find_each do |agent|
        # Assign a random password
        unless agent.encrypted_password.present?
          random_password = Devise.friendly_token(8)
          agent.password = random_password
          agent.save
          AgentMailer.password_reset(agent, random_password).deliver_later
        end
      end
    rescue Exception => e
      puts "Error: #{e.message}"
    end
  end
end
