# Let's Export Scrollytelling

## Step 1 **(You are here)**

Use the script to create an `index.json` for each Scrollytelling account.

To run it:

$scrolly_home: the Rails app root
$export_home: where all the Scrolly export stuff is

``` shell
# in a folder that will become the web root:
${scrolly_home}bin/rails runner ${export_home}/step_1_build_index/published_entries.rb
```
