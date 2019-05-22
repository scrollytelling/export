Download an entire scrollytelling to a folder, with all media included.

It will become a plain old static HTML website that you can put on almost anything. (Maybe not your shoes, but do try!)

📗🌇📽🎹 ➡️➡️➡️ 💾📂

# THE END GAME

- hu.scrollytelling.io/
  - afvallen via je onderbewustzijn/
  - afvallen via je onderbewustzijn/index.html
  - afvallen via je onderbewustzijn/screenshots/

  - media.scrollytelling.com/
  - output.scrollytelling.com/

  - reports/

  - scrollytelling.link/
    - assets/
    - entries

  - index.atom
  - index.json
  - index.html
  - robots.txt
  - humans.txt

  - archive/scrollies.css
  - archive/bundle.js
  - archive/scrollytelling.png
  - archive/scrollytelling.svg

# USAGE

After you've cloned this repository, do this:

``` shell
bin/export cname-to-be-exported
bin/export stories.scrollytelling.com # for example
```

Now sit back and enjoy the show! Your already tiny contribution as a human is now complete. 🏅 Bow for the all-mighty robots, doing thankless dirty work without complaining.

If you need more information, check each folder's README.

# RESULTS!

A folder, named after the hostname of the story, will have been created.

To see the results of your effort:

``` shell
cd <hostname of the story>
http-server # let's assume you have nodejs installed... use python -m HTTPServer otherwise
```

When you open the inspector, all elements should come from localhost. File a bug if not!

# CAVEATS

### s3 output bucket 📂

You're gonna need access to our media buckets on S3. We need it to sync all of the files,
because the page sources does not contain links to everything.

# TRANSFER, TOOT TOOT!

In all seriousness, where to put everything?!

Let's go with **S3** for this one! Pretend we want to store `account.scrollytelling.com`:

``` shell
aws s3 sync account.scrollytelling.com "s3://your-bucket-name/account.scrollytelling.com/" --acl public-read --cache-control "public, max-age=31536000"
```

**or...**

Or you might want to transfer the lot to or from a **"Cloud Server"**. Here's how.

The idea is to place an entire Document Root directory on the remote.

``` shell
# this will recreate `account.scrollytelling.com` on the remote.
rsync \
  --chmod=a=rwX \
  --compress \
  --human-readable \
  --no-owner \
  --partial-dir=.rsync \
  --progress \
  --recursive \
  --safe-links \
  --times \
  --verbose \

  account.scrollytelling.com root@example.com:/var/www
```

# AUTHOR

Joost Baaij

joost@spacebabies.nl

www.spacebabies.nl
