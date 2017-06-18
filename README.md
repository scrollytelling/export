Download an entire scrollytelling to a folder, with all media included.

📗🌇📽🎹 ➡️➡️➡️ 💾📂

# USAGE

After you've cloned this repository, do this:

```
bash scrollytelling-export.bash <URL of the story, without the #hash at the end}
```

# RESULTS!

A folder, named after the hostname of the story, will have been created.

Too see the results of your leeching:

```
cd <hostname of the story>
http-server # let's assume you have nodejs installed... use python -m HTTPServer otherwise
```

When you open the inspector, all elements should come from localhost. File a bug if not!

# CAVEATS

It assumes BSD sed (which is on OSX), not GNU sed.

# AUTHOR

Joost Baaij

joost@spacebabies.nl

www.spacebabies.nl
