# Let's Export Scrollytelling

## Step 1 **(You are here)**

Use the script to create an `index.json` for each Scrollytelling account.

To run it:

``` shell
$SCROLLY_HOME/bin/rails runner published_entries.rb
```

It assumes output dir is `../entries`.

### Rebuilding chapters

There is a separate script to update all chapters in all indexes.

``` shell
ruby update_chapters.rb
```
