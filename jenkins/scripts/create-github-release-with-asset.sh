#!/usr/bin/env bash
#
# Parameters:
#
# user
# token
#
# Example:
#
# create-github-release-with-asset.sh user=rriddick token=TOKEN
#

# Exit immediately if a pipeline, which may consist of a single simple command, a list, or a compound command returns a non-zero status. 
set -e
# xargs is a command on Unix and most Unix-like operating systems used to build and execute commands from standard input. 
# It converts input from standard input into arguments to a command.
# Don't understand really!?
xargs=$(which gxargs || which xargs)

# Validate settings.
# set -x will print a trace of simple commands  
[ "$TRACE" ] && set -x

CONFIG=$@

for line in $CONFIG; do
  eval "$line"
done

HOST="api.github.com"
USER="$user"
TOKEN="$token"
REPO_OWNER="pitchblack408"
REPO="simple-java-maven-app"
POM_DIR="/var/jenkins_home/workspace/simple-java-maven-app/"
ARTIFACT_ID=$(cd $POM_DIR && mvn org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate -Dexpression=project.artifactId|grep -Ev '(^\[|Download\w+:)')
TAG_NAME=$(cd $POM_DIR && mvn org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate -Dexpression=project.version|grep -Ev '(^\[|Download\w+:)')
FINAL_NAME="$ARTIFACT_ID-$TAG_NAME.jar"
FILE_NAME="/var/jenkins_home/workspace/simple-java-maven-app/target/$FINAL_NAME"
NAME=$TAG_NAME
DESC=$(cd $POM_DIR && mvn org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate -Dexpression=project.description|grep -Ev '(^\[|Download\w+:)')
echo "Trying to create git release tag_name:name=$TAG_NAME:$NAME"
echo "Description=$DESC"
RESULT1=$(curl --trace-ascii dump1.txt --user "$USER:$TOKEN" -H "Content-Type: application/json" -H "Accept: application/json" --data "{\"tag_name\":\"$TAG_NAME\",  \"target_commitish\":\"master\", \"name\":\"$NAME\", \"body\":\"$DESC\", \"draft\":false, \"prerelease\": false}" https://$HOST/repos/$REPO_OWNER/$REPO/releases)
echo $RESULT1
RELEASE_ID=$(echo $RESULT1 | jq '.id')
echo "Uploading asset with release id: $RELEASE_ID"
echo "Filename: $FILE_NAME"
GH_ASSET="https://uploads.github.com/repos/$REPO_OWNER/$REPO/releases/$RELEASE_ID/assets?name=$(basename $FILE_NAME)"
RESULT2=$(curl --trace-ascii dump2.txt --user "$USER:$TOKEN"  -H "Content-Type: application/jar" --data-binary @"$FILE_NAME" $GH_ASSET)
echo $RESULT2