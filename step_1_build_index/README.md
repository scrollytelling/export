# Let's Export Scrollytelling

## Step 1 **(You are here)**

Use the script to create an `index.json` for a Scrollytelling account. It will
be the focus point for the entire archive.

To run it:

``` shell
➜ $scrollytelling/bin/rails runner step_1_build_index/published_entries.rb $hostname
➜ step_1_build_index/media_folders $hostname | parallel "aws s3 sync s3://{} ${HOME}/${hostname}/{}"
➜ step_1_build_index/output_folders $hostname | parallel "aws s3 sync s3://{} ${HOME}/${hostname}/{}"

```

It assumes output dir is $HOME.

## RESULT

Afterwards you should see something like this:

``` shell
~/$hostname
~/$hostname/index.json # if you only care about one thing...
~/$hostname/archive # static html to browse
~/$hostname/media.scrollytelling.com # photos used in the stories
~/$hostname/output.scrollytelling.com # videos/audio used in the stories
~/$hostname/scrollytelling.link # css/js used in the stories

```

# Questioni?

Joost Baaij <joost@spacebabies.nl>
