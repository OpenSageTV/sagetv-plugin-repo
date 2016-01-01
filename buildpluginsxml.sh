#!/bin/sh

PLUGINFILE=SageTVPluginsV9.xml
PLUGINMD5=SageTVPluginsV9.md5
TMPFILE=SageTVPluginsV9TMP.xml
DATE=`date +%Y.%0m%0d.%0H%0M`

echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > $TMPFILE
echo "<PluginRepository version=\"${DATE}\">" >> $TMPFILE
# finding regular xml manifests
cat `find plugins/ -iname '*.xml' -exec echo {} \;` | grep -v '<?xml ' >> $TMPFILE

# resolve .url locators
mkdir tmp
cd tmp
for file in `find ../plugins/ -name '*.url'` ; do
    if [ -e tmp.xml ] ; then
       rm tmp.xml
    fi
    url=`cat $file | head -n1`
    echo "Resolving Reference URL $url"
    wget -O tmp.xml "$url"
    if [ $? -ne 0 ]
    then
        echo "Failed to resolve $url.  Skipping..."
    else
        echo "Adding $URL"
        cat tmp.xml | grep -v '<?xml ' >> ../$TMPFILE
    fi
done
cd ..

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