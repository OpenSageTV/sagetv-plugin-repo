# SageTV Plugin Repository for V9


[![Build Status](https://travis-ci.org/OpenSageTV/sagetv-plugin-repo.svg?branch=master)](https://travis-ci.org/OpenSageTV/sagetv-plugin-repo)

This is a plugin repository (ie, XML manifest repository) for SageTV V9 Open Source Plugins.

Developers should clone this repository, then add a new plugin under the `plugins` directory.

You can add more than one xml in your folder, but, the start and end of each xml file should be

`<SageTVPlugin>...</SageTVPlugin>`

ie, the plugin xml is exactly the same as your Plugin's Manifest.

When you commit your changes, create a `PULL REQUEST` and your plugin manifest will be included (at some timed interval, usually once a day, or sooner)

Do not edit the `SageTVPluginsV9.xml` file.  This file is automatically re-generated based on the content in the `plugins` directory.

Please note there is no code in this git repo.  This repo is strictly for maintaining the SageTV V9 Plugin Repository XML manifest files.  Your actual plugin should exist elsewhere in a git repository.

## Step by Step Add a new Plugin

1. If you haven't forked the repository, then fork this repository.  You will see a `fork` button near the top right below the github black banner.  Click that.

2. If you haven't cloned your forked repository, then clone it.  Click on the green `clone or download` button and choose whether or not to close using `https` or `ssh`.  Only use `ssh` if you've actually setup ssh keys on github.

3. (This step is only required if you care about getting updates from the main repository).  If you have fork, and you haven't updated it from the master repo, you'll want to do that first.  You can use the [Browser](https://github.com/KirstieJane/STEMMRoleModels/wiki/Syncing-your-fork-to-the-original-repository-via-the-browser) or follow these steps.
    1. Configure the ability to pull from the [upstream](https://help.github.com/articles/configuring-a-remote-for-a-fork/]).  `upstream` means the main repo.
    2. [Sync](https://help.github.com/articles/syncing-a-fork/) from the `upstream` into your current fork.
    
4. Add your plugin.  In `plugins` folder, just create your plugin xml.

5. Check in your changes
    1. `git add path/to/your/plugin.xml`
    2. `git commit -m 'added/updated plugin XXX'`
       
6. Push your changes to your repo
    1. `git push`
    
7. Create a Pull Request from your Repo to the SageTV Plugin Repo.
    1. Open you Github Repo in a browser.
    2. Just above the file list, on the right, there are two buttons/links `Pull Request` and `Compare`.  Click `Pull Request`
    3. You should see a bright green button `Create pull request`.  Click that button. (`NOTE` above this button it shows the 2 repository and it should show the text `Able to merge` in green.  If it doesn't show that, it means your repo is not up to date, and you should do step `3.2` first)
    4. You should see a bright green button `Create pull request`.  Click that button. (this second step will submit the pull request and from there, there is nothing you do, except wait for it to be accepted)    
 
## Adding a New Library
If all you are doing is adding/updating a new jar file library.  You might be able to simpled edit/add a file in the `src/libraries.in` folder.  In this folder each library has a very simple xml that contains something like.
```xml
<!-- http://central.maven.org/maven2/com/google/code/gson/gson/2.7/gson-2.7.jar -->
<dependency org="com.google.code.gson" name="gson" rev="2.7"/>
```

This is basically a copy/paste of the `ivy` dependency from `maven central`.  Normally I find the library, and then copy the IVY xml into a library xml file here.

Once you add/edit the library xml, you can run, 
```bash
gradlew copyLibraries
```

This will covert these simple xml files into a SageTV plugin xml files and then copy them to the `plugins/libraries/` folder.

From here you can publish this using the process above.
