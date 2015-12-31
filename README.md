# SageTV Plugin Repository for V9

This is a plugin repository (ie, XML manifest repository) for SageTV V9 Open Source Plugins.

Developers should clone this repository, then add a new plugin under the `plugins` directory.

You can add more than one xml in your folder, but, the start and end of each xml file should be

`<SageTVPlugin>...</SageTVPlugin>`

ie, the plugin xml is exactly the same as your Plugin's Manifest.

When you commit your changes, create a `PULL REQUEST` and your plugin manifest will be included (at some timed interval, usually once a day, or sooner)

Do not edit the `SageTVPluginsV9.xml` file.  This file is automatically re-generated based on the content in the `plugins` directory.

Please note there is no code in this git repo.  This repo is strictly for maintaining the SageTV V9 Plugin Repository XML manifest files.  Your actual plugin should exist elsewhere in a git repository.

