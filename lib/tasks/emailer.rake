namespace :emailer do   
    desc 'Task to check your email for all projects that use the ticket_emailer plugin.'
    task :check_mail => :environment do
        MailReader.check_mail            
    end
end
