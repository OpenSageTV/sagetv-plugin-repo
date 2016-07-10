#!/bin/bash

#
# This script will rebuild and redeploy the SageTVPuginsV9.xml
# it should be called like the following
# GIT_COMMIT=true GIT_TOKEN=git_username:git_pat ./buildpluginsxml.sh
#

PLUGIN_DIR=${PLUGIN_DIR:-XXX}
PLUGIN_BASENAME=${PLUGIN_BASENAME:-XXX}
PLUGIN_FILE=${PLUGIN_BASENAME}.xml
PLUGIN_MD5=${PLUGIN_BASENAME}.md5
TMP_FILE=${PLUGIN_BASENAME}TMP.xml
VERSION=`date +%Y.%0m%0d.%0H%0M`
FAILED_PLUGINS=""
GIT_REPO=OpenSageTV/sagetv-plugin-repo.git

echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > ${TMP_FILE}
echo "<PluginRepository version=\"${VERSION}\">" >> ${TMP_FILE}

# finding regular xml manifests
for file in `find ${PLUGIN_DIR}/ -name '*.xml'` ; do
    # validate the xml we just got
    xmllint --noout ${file}
    if [ $? -eq 0 ] ; then
      echo "Adding Plugin $file"
      cat ${file} | grep -v '<?xml ' >> ${TMP_FILE}
    else
      FAILED_PLUGINS="${FAILED_PLUGINS} ${file}"
      echo "XML File for ${file} is not valid.  Skipping..." >&2
    fi
done


# resolve .url locators
mkdir tmp
cd tmp
for file in `find ../${PLUGIN_DIR}/ -name '*.url'` ; do
    if [ -e tmp.xml ] ; then
       rm tmp.xml
    fi
    url=`cat ${file} | head -n1`
    echo "Resolving Reference URL $url"
    wget -O tmp.xml "$url"
    if [ $? -ne 0 ] ; then
        FAILED_PLUGINS="${FAILED_PLUGINS} ${file}"
        echo "Failed to resolve $url in ${file}.  Skipping..."
    else
        # validate the xml we just got
        xmllint --noout tmp.xml
        if [ $? -eq 0 ]
        then
          echo "Adding Plugin from $url"
          cat tmp.xml | grep -v '<?xml ' >> ../${TMP_FILE}
        else
          FAILED_PLUGINS="${FAILED_PLUGINS} ${file}"
          echo "XML File for ${url} is not valid.  Skipping ${file} ..." >&2
        fi
    fi
done
cd ..
rm -rf tmp

echo '</PluginRepository>' >> ${TMP_FILE}

# before we carry on, let's validate if anything actually changed.
diff <(grep -v "<PluginRepository" ${PLUGIN_FILE}) <(grep -v "<PluginRepository" ${TMP_FILE}) > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "Nothing Changed, so let's exit"
    rm -f ${TMP_FILE}
    exit 0;
fi

# it appears that we have some updates, so, let's validate
# now validate the entire composited xml file to make sure it is valid
xmllint --noout ${TMP_FILE}
if [ $? -eq 0 ]; then
  rm ${PLUGIN_FILE}
  mv ${TMP_FILE} ${PLUGIN_FILE}

  # generate the md5 checksum
  md5sum ${PLUGIN_FILE} | tr " " "\n" | grep -v 'xml' > ${PLUGIN_MD5}
  echo ""
  echo ""

  if [ "$FAILED_PLUGINS" != "" ] ; then
    echo ""
    echo ""
    echo "Successfully created ${PLUGIN_FILE} and ${PLUGIN_MD5} BUT Some plugins are omitted"
    echo "** PLUGIN FAILURES **"
    echo "$FAILED_PLUGINS"
    echo "** PLUGIN FAILURES **"
  else
    echo "Successfully created ${PLUGIN_FILE} and ${PLUGIN_MD5}"
  fi
else
  echo ""
  echo ""
  echo "XML File is not valid"
  if [ "$FAILED_PLUGINS" != "" ] ; then
    echo "** PLUGIN FAILURES **"
    echo "$FAILED_PLUGINS"
    echo "** PLUGIN FAILURES **"
    exit 2
  fi
fi

#
# Last Step commit these new changes
if [ "true" = "$GIT_COMMIT" ] ; then
  if [ -z "$GIT_TOKEN" ] ; then
    echo "missing GIT_TOKEN"
    echo "GIT_TOKEN should be user:personal_access_token used to authenticate the user"
    exit 1
  fi

  mkdir tmp
  cd tmp
  git config --global push.default matching
  git config --global user.email "sean.stuckless@gmail.com"
  git config --global user.name "Travis CI Builder"
  git clone https://${GIT_TOKEN}@github.com/${GIT_REPO}
  if [ $? -ne 0 ]; then
    cd ..
    rm -rf tmp
    echo "Failed to clone Git Rep"
    exit 3
  fi

  cd sagetv-plugin-repo
  echo "Committing Changed Files to Git"
  cp ../../${PLUGIN_FILE} .
  cp ../../${PLUGIN_MD5} .
  git add ${PLUGIN_FILE}
  git add ${PLUGIN_MD5}
  git commit -m "[ci skip] updated plugins xml to $VERSION"
  if [ $? -ne 0 ]; then
    cd ../../
    rm -rf tmp
    echo "Failed to commit git changes"
    exit 4
  fi
  # nuke the output for git push since it contains our url
  git push > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    cd ../../
    rm -rf tmp
    echo "Failed to push changes"
    exit 4
  fi
  cd ../../
  rm -rf tmp
  echo "Re-published $PLUGIN_FILE"
fi
