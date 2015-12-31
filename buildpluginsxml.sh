#!/bin/sh

PLUGINFILE=SageTVPluginsV9.xml
PLUGINMD5=SageTVPluginsV9.md5
TMPFILE=SageTVPluginsV9TMP.xml
DATE=`date +%Y.%0m%0d.%0H%0M`

echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > $TMPFILE
echo "<PluginRepository version=\"${DATE}\">" >> $TMPFILE
cat `find plugins/ -iname '*.xml' -exec echo {} \;` >> $TMPFILE
echo '</PluginRepository>' >> $TMPFILE

xmllint --noout $TMPFILE
if [ $? -eq 0 ]
then
  rm $PLUGINFILE
  mv $TMPFILE $PLUGINFILE
  md5sum $PLUGINFILE | tr " " "\n" | grep -v 'xml' > $PLUGINMD5
  echo "Successfully created ${PLUGINFILE} and ${PLUGINMD5}"
else
  echo "XML File is not valid" >&2
fi