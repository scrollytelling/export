ALTER TABLE pageflow_accounts_themes
ADD FOREIGN KEY IF NOT EXISTS fk_accounts_theme(account_id)
REFERENCES pageflow_accounts(id)
ON DELETE CASCADE;

ALTER TABLE pageflow_folders
ADD FOREIGN KEY IF NOT EXISTS fk_folder(account_id)
REFERENCES pageflow_accounts(id)
ON DELETE CASCADE;

ALTER TABLE pageflow_themings
ADD FOREIGN KEY IF NOT EXISTS fk_theming(account_id)
REFERENCES pageflow_accounts(id)
ON DELETE CASCADE;

ALTER TABLE pageflow_entries
ADD FOREIGN KEY IF NOT EXISTS fk_entry(account_id)
REFERENCES pageflow_accounts(id)
ON DELETE CASCADE;

ALTER TABLE pageflow_entries
ADD FOREIGN KEY IF NOT EXISTS fk_entry(folder_id)
REFERENCES pageflow_folders(id)
ON DELETE CASCADE;

ALTER TABLE pageflow_entries
ADD FOREIGN KEY IF NOT EXISTS fk_entry(theming_id)
REFERENCES pageflow_themings(id)
ON DELETE CASCADE;

DELETE FROM pageflow_image_files
WHERE entry_id
NOT IN ( select id from pageflow_entries );

ALTER TABLE pageflow_image_files
ADD FOREIGN KEY IF NOT EXISTS fk_image_file(entry_id)
REFERENCES pageflow_entries(id)
ON DELETE CASCADE;

DELETE FROM pageflow_revisions
WHERE entry_id
NOT IN ( select id from pageflow_entries );

ALTER TABLE pageflow_revisions
ADD FOREIGN KEY IF NOT EXISTS fk_revision(entry_id)
REFERENCES pageflow_entries(id)
ON DELETE CASCADE;

ALTER TABLE pageflow_text_track_files
ADD FOREIGN KEY IF NOT EXISTS fk_text_track(entry_id)
REFERENCES pageflow_entries(id)
ON DELETE CASCADE;

DELETE FROM pageflow_video_files
WHERE entry_id
NOT IN ( select id from pageflow_entries );

ALTER TABLE pageflow_video_files
ADD FOREIGN KEY IF NOT EXISTS fk_video_file(entry_id)
REFERENCES pageflow_entries(id)
ON DELETE CASCADE;

DELETE FROM pageflow_audio_files
WHERE entry_id
NOT IN ( select id from pageflow_entries );

ALTER TABLE pageflow_audio_files
ADD FOREIGN KEY IF NOT EXISTS fk_audio_file(entry_id)
REFERENCES pageflow_entries(id)
ON DELETE CASCADE;

DELETE FROM pageflow_storylines
WHERE revision_id
NOT IN ( select id from pageflow_revisions );

ALTER TABLE pageflow_storylines
ADD FOREIGN KEY IF NOT EXISTS fk_storyline(revision_id)
REFERENCES pageflow_revisions(id)
ON DELETE CASCADE;

DELETE FROM pageflow_external_links_sites
WHERE revision_id
NOT IN ( select id from pageflow_revisions );

ALTER TABLE pageflow_external_links_sites
ADD FOREIGN KEY IF NOT EXISTS fk_external_links_site(revision_id)
REFERENCES pageflow_revisions(id)
ON DELETE CASCADE;

DELETE FROM pageflow_file_usages
WHERE revision_id
NOT IN ( select id from pageflow_revisions );

ALTER TABLE pageflow_file_usages
ADD FOREIGN KEY IF NOT EXISTS fk_file_usage(revision_id)
REFERENCES pageflow_revisions(id)
ON DELETE CASCADE;

DELETE FROM pageflow_chapters
WHERE storyline_id
NOT IN ( select id from pageflow_storylines );

ALTER TABLE pageflow_chapters
ADD FOREIGN KEY IF NOT EXISTS fk_chapter(storyline_id)
REFERENCES pageflow_storylines(id)
ON DELETE CASCADE;

DELETE FROM pageflow_pages
WHERE chapter_id
NOT IN ( select id from pageflow_chapters );

ALTER TABLE pageflow_pages
ADD FOREIGN KEY IF NOT EXISTS fk_page(chapter_id)
REFERENCES pageflow_chapters(id)
ON DELETE CASCADE;

ALTER TABLE pageflow_memberships
ADD FOREIGN KEY IF NOT EXISTS fk_member(user_id)
REFERENCES users(id)
ON DELETE CASCADE;
