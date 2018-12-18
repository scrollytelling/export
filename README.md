Download an entire scrollytelling to a folder, with all media included.

📗🌇📽🎹 ➡️➡️➡️ 💾📂

# USAGE

After you've cloned this repository, do this.

# 🥇

First order of business: generate an `index.json` for each published
story. This file is going to be the main entry point for each story.

``` bash
cd ${one dir above the future web roots}
${SCROLLY_HOME}/bin/rails runner ${EXPORT_HOME}/published_entry/entries.rb
```

When that's done, you should have one folder for every Scrollytelling account.

``` bash
cd files
ruby scrape.rb
```

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
