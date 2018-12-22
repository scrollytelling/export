# Let's Export Scrollytelling

## Step 1 **(You are here)**

Use the script to create an `index.json` for each Scrollytelling account.

To run it:

``` shell
# this directory will have one document root per account
cd /var/www

${scrolly_rails_root}/bin/rails runner ${export-scripts}/step_1_build_index/published_entries.rb
```
