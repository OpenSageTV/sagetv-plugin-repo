#!/bin/sh

PLUGINFILE=SageTVPluginsV9.xml
PLUGINMD5=SageTVPluginsV9.md5
TMPFILE=SageTVPluginsV9TMP.xml
DATE=`date +%Y.%0m%0d.%0H%0M`
FAILED=""

echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > $TMPFILE
echo "<PluginRepository version=\"${DATE}\">" >> $TMPFILE

# finding regular xml manifests
for file in `find plugins/ -name '*.xml'` ; do
    # validate the xml we just got
    xmllint --noout $file
    if [ $? -eq 0 ] ; then
      echo "Adding Plugin $file"
      cat $file | grep -v '<?xml ' >> $TMPFILE
    else
      FAILED="${FAILED} ${file}"
      echo "XML File for ${file} is not valid.  Skipping..." >&2
    fi
done


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
    if [ $? -ne 0 ] ; then
        FAILED="${FAILED} ${file}"
        echo "Failed to resolve $url in ${file}.  Skipping..."
    else
        # validate the xml we just got
        xmllint --noout tmp.xml
        if [ $? -eq 0 ]
        then
          echo "Adding Plugin from $url"
          cat tmp.xml | grep -v '<?xml ' >> ../$TMPFILE
        else
          FAILED="${FAILED} ${file}"
          echo "XML File for ${url} is not valid.  Skipping ${file} ..." >&2
        fi
    fi
done
cd ..
rm -rf tmp

echo '</PluginRepository>' >> $TMPFILE

# now validate the entire composited xml file to make sure it is valid
xmllint --noout $TMPFILE
if [ $? -eq 0 ]; then
  rm $PLUGINFILE
  mv $TMPFILE $PLUGINFILE

  # generate the md5 checksum
  md5sum $PLUGINFILE | tr " " "\n" | grep -v 'xml' > $PLUGINMD5
  echo ""
  echo ""

  if [ "$FAILED" != "" ] ; then
    echo ""
    echo ""
    echo "Successfully created ${PLUGINFILE} and ${PLUGINMD5} BUT Some plugins are omitted"
    echo "** PLUGIN FAILURES **"
    echo "$FAILED"
    echo "** PLUGIN FAILURES **"
  else
    echo "Successfully created ${PLUGINFILE} and ${PLUGINMD5}"
  fi
else
  echo ""
  echo ""
  echo "XML File is not valid" >&2
  if [ "$FAILED" != "" ] ; then
    echo "** PLUGIN FAILURES **"
    echo "$FAILED"
    echo "** PLUGIN FAILURES **"
  fi
fi

