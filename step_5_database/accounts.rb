def write_strip(account)
  File.open("./strip-#{account.parameterize}.sql", 'wt') do |file|
    file.puts stripper(account)
  end
end

def stripper(account)
  <<~STRIP
    DROP TABLE IF EXISTS pageflow_edit_locks;
    DROP TABLE IF EXISTS active_admin_comments;
    DROP TABLE IF EXISTS schema_migrations;

    DELETE FROM pageflow_accounts
    WHERE name <> '#{account}';

    DELETE FROM pageflow_widgets
    WHERE subject_type = 'Pageflow::Revision'
    AND subject_id not in ( select id from pageflow_revisions );

    DELETE FROM pageflow_widgets
    WHERE subject_type = 'Pageflow::Theming'
    AND subject_id not in ( select id from pageflow_themings );

    DELETE FROM pageflow_memberships
    WHERE entity_type = 'Pageflow::Account'
    AND entity_id not in ( select id from pageflow_accounts );

    DELETE FROM pageflow_memberships
    WHERE entity_type = 'Pageflow::Entry'
    AND entity_id not in ( select id from pageflow_entries );

    DELETE FROM users
    WHERE id not in ( select user_id from pageflow_memberships );

    DELETE FROM pageflow_file_usages
    WHERE file_type = 'Pageflow::ImageFile'
    AND file_id not in ( select id from pageflow_image_files );

    DELETE FROM pageflow_file_usages
    WHERE file_type = 'Pageflow::AudioFile'
    AND file_id not in ( select id from pageflow_audio_files );

    DELETE FROM pageflow_file_usages
    WHERE file_type = 'Pageflow::VideoFile'
    AND file_id not in ( select id from pageflow_video_files );
  STRIP
end

puts "# in `mysql -uroot`:"
Pageflow::Account.find_each do |account|
  puts "CREATE DATABASE #{account.name.parameterize};"
end

puts
puts "# in a shell:"
Pageflow::Account.find_each do |account|
  write_strip(account.name)

  puts "mysql -uroot #{account.name.parameterize} < ../databases/scrollytelling.sql"
  puts "mysql -uroot #{account.name.parameterize} < ./cascade.sql"
  puts "mysql -uroot #{account.name.parameterize} < ./strip-#{account.name.parameterize}.sql"
  puts "mysqldump -uroot #{account.name.parameterize} > ../databases/#{account.name.parameterize}.sql"
  puts
end
