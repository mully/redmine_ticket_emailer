class MailReader < ActionMailer::Base

  def receive(email)         
        
    issue = Issue.create(
        :subject => email.subject,
        :description => email.body,
        :priority_id => 3,
        :project_id => @@project.id,
        :tracker_id => 3,
        :author_id => 2,
        :status_id => 1        
    )
    
    if email.has_attachments?
        for attachment in email.attachments        
            Attachment.create(:container => issue, 
                                  :file => attachment,
                                  :description => "",
                                  :author_id => 2)
        end
    end

  end
  
  def self.check_mail
  
     begin
       require 'net/imap'
     rescue LoadError
       raise RequiredLibraryNotFoundError.new('NET::Imap could not be loaded')
     end

     @@config_path = (RAILS_ROOT + '/config/emailer.yml')
     
     # Cycle through all of the projects created in the yaml file
     YAML.load_file(@@config_path).keys.each do |project_name|
     
        #Find the project based off the name in the YAML if the emailer is enabled in Redmine
        @@project = Project.find_by_name project_name, :include=>:enabled_modules , :conditions=>"enabled_modules.name='ticket_emailer'"

        unless @@project.nil?
            @@config = YAML.load_file(@@config_path)[project_name].symbolize_keys
                 
            imap = Net::IMAP.new(@@config[:email_server], port=@@config[:email_port], usessl=@@config[:use_ssl])
             
            imap.login(@@config[:email_login], @@config[:email_password])
            imap.select(@@config[:email_folder])  
                     
            imap.search(['ALL']).each do |message_id|
              msg = imap.fetch(message_id,'RFC822')[0].attr['RFC822']
              MailReader.receive(msg)          
              #Mark message as deleted and it will be removed from storage when user session closd
              imap.store(message_id, "+FLAGS", [:Deleted])
            end
            # tell server to permanently remove all messages flagged as :Deleted
            imap.expunge()
        end
    end
  end
  
  def attach_files(obj, attachment)
    attached = []
    user = User.find 2
    if attachment && attachment.is_a?(Hash)
        file = attachment['file']
#        if file.size > 0
            Attachment.create(:container => obj, 
                                  :file => file,
                                  :author => user)
#        end
        attached << a unless a.new_record?
    end
    attached
  end
  
private

  def connect_to_email
     begin
       require 'net/imap'
     rescue LoadError
       raise RequiredLibraryNotFoundError.new('NET::Imap could not be loaded')
     end

     begin
       @@config_path = (RAILS_ROOT + '/config/emailer.yml')
       @@config = YAML.load_file(@@config_path)['mindbites'].symbolize_keys
     end
             
     imap = Net::IMAP.new(@@config[:email_server], port=@@config[:email_port], usessl=@@config[:use_ssl])
     
     imap.login(@@config[:email_login], @@config[:email_password])
     imap.select(@@config[:email_folder])  
  end

end
