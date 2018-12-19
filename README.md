Download an entire scrollytelling to a folder, with all media included.

📗🌇📽🎹 ➡️➡️➡️ 💾📂

# USAGE

After you've cloned this repository, do this.

# 🥇

First order of business: generate an `index.json` for each published
story. This file is going to be the main entry point for each story.

``` bash
cd ${one dir above the future web roots}
${SCROLLY_HOME}/bin/rails runner ${EXPORT_HOME}/step_1_build_index/published_entries.rb
```

When that's done, you should have one folder for every Scrollytelling account.

Inside those folders should be one folder for every published story. Good? We good.

Time to fetch all those sweet media files.

# 🥈

Next we need to scrape Scrollytelling admin for media files. Because this
tends to get very big, it is done per account. All variables need to be passed
to the script on the command line.

``` bash
cd step_2_scrape_media
ACCOUNT=app.scrollytelling.com EMAIL=admin@scrollytelling.com PASSWORD=letmeinplease ruby scrape.rb
```

This will sync all the media straight from S3. It assumes a `../entries` directory
exists, with account directories under it. It will write a manifest of all
media it finds into the `index.json` of each archive, too.

# RESULTS!

A folder, named after the hostname of the story, will have been created.

Too see the results of your leeching:

``` bash
cd <hostname of the story>
http-server # let's assume you have nodejs installed... use python -m HTTPServer otherwise
```

When you open the inspector, all elements should come from localhost. File a bug if not!

# CAVEATS

### List of stories

At the moment we rely on a static list of stories in `published_entries`. If stories
are missing, update that file and rerun everything.

### s3 output bucket 📂

You're gonna need access to our media buckets on S3. We need it to sync all of the files,
because the page sources does not contain links to everything.

# LONG-TERM STORAGE

Let's go with S3 for this one! Pretend we want to store `houdenvan.edvanderelsken.amsterdam`:

``` bash
aws s3 sync houdenvan.edvanderelsken.amsterdam "s3://your-bucket-name/houdenvan.edvanderelsken.amsterdam/" --cache-control "public, max-age=31536000"
```

# AUTHOR

Joost Baaij

joost@spacebabies.nl

www.spacebabies.nl
