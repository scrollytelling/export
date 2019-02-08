# Let's Export Scrollytelling

## Step 1 **(You are here)**

Use the script to create an `index.json` for each Scrollytelling account.

To run it:

``` shell
$SCROLLY_HOME/bin/rails runner published_entries.rb
```

It assumes output dir is `../entries`.

When that's done, you should have one folder for every Scrollytelling account.

Inside those folders should be one folder for every published story. Good? We good.

Time to fetch all those sweet media files.



### Rebuilding chapters

There is a separate script to update all chapters in all indexes.

``` shell
ruby update_chapters.rb
```
