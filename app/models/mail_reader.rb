require 'net/imap'

class MailReader < ActionMailer::Base

  def receive(email)         
        
    issue = Issue.new(
        :subject => email.subject,
        :description => email.body,
        :priority_id => 3,
        :project_id => @@project.id,
        :tracker_id => 3,
        :author_id => 2,
        :status_id => 1        
    )
    issue.save    
    
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
    # Find all of the projects that have enabled the "ticket emailer" plugin
    @projects = Project.find :all, :include=>:enabled_modules, :conditions=>"enabled_modules.name='ticket_emailer'"

    @projects.each do |@@project|
    
        email_server = @@project.custom_values.detect {|v| v.custom_field_id == Setting.plugin_ticket_emailer['email_server'].to_i}        
        email_server = email_server.value if email_server
        
        email_login = @@project.custom_values.detect {|v| v.custom_field_id == Setting.plugin_ticket_emailer['email_login'].to_i}      
        email_login = email_login.value if email_login
        
        email_password = @@project.custom_values.detect {|v| v.custom_field_id == Setting.plugin_ticket_emailer['email_password'].to_i}   
        email_password = email_password.value if email_password
        
        email_folder = @@project.custom_values.detect {|v| v.custom_field_id == Setting.plugin_ticket_emailer['email_folder'].to_i}  
        email_folder = email_folder.value if email_folder
        
        use_ssl = @@project.custom_values.detect {|v| v.custom_field_id == Setting.plugin_ticket_emailer['use_ssl'].to_i} 
        use_ssl = use_ssl.value if use_ssl
        
        email_port = @@project.custom_values.detect {|v| v.custom_field_id == Setting.plugin_ticket_emailer['email_port'].to_i}
        email_port = email_port.value.to_i if email_port
                
        imap = Net::IMAP.new(email_server, port=email_port, usessl=use_ssl)

        imap.login(email_login, email_password)
        imap.select(email_folder)
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

end
