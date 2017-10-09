Download an entire scrollytelling to a folder, with all media included.

📗🌇📽🎹 ➡️➡️➡️ 💾📂

# USAGE

After you've cloned this repository, do this:

```
bash export.bash <URL of the story, without the #hash at the end}
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

### gnu xargs/findutils 🔍

On OSX, You're gonna need the GNU tools for this one. Especially xargs.

```
brew install findutils
```

### s3 output bucket 📂

You're also gonna need access to our output bucket on S3, since the HTML doesn't contain any of the files needed for http streaming (HLS and MPEG-DASH). Without these files, you'll still get the full video files though.

# LONG-TERM STORAGE

Let's go with S3 for this one! Pretend we want to store `houdenvan.edvanderelsken.amsterdam`:

``` bash
aws s3 sync houdenvan.edvanderelsken.amsterdam "s3://your-bucket-name/houdenvan.edvanderelsken.amsterdam/" --cache-control "public, max-age=31536000"
```

# AUTHOR

Joost Baaij

joost@spacebabies.nl

www.spacebabies.nl
