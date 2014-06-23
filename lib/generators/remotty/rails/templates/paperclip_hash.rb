# The secret key used by Paperclip.
Paperclip::Attachment.default_options.update({
                                               :url => '/system/:class/:attachment/:id_partition/:style/:hash.:extension',
                                               :default_url => ''
                                             })
