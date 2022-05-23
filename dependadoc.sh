#!/bin/bash

set -eo pipefail

# working directory has been set as ./${{ inputs.docs-repository }}

# env: (from action.yml)
  # MIRRORED_FOLDER: ${{ inputs.mirrored-folder }}
  # MIRRORED_REPOSITORY_FULL_NAME: $GITHUB_REPOSITORY
  # DOCS_REPOSITORY_PATH: ${{ inputs.docs-repository-path}}
  # GITHUB_ACTOR: $GITHUB_ACTOR

# get mirrored repo name (no owner)
MIRRORED_REPO=$(echo ${MIRRORED_REPOSITORY_FULL_NAME##*/})

# create a new branch inside docs repo
git switch -c dependadoc-${MIRRORED_REPO}-$(date +%F)

# configure some settings
git config user.name $GITHUB_ACTOR
git config user.email via-github-actions@github.com

# copy files
cp -rf ../main/$MIRRORED_FOLDER  $DOCS_REPOSITORY_PATH/mirrored-${MIRRORED_REPO}

# add changes
git add .

# generate file list
FILE_LIST=$(git status --porcelain)

# exit if file list indicates there are no changes
if [ -z $FILE_LIST ]; then exit

# commit the changes
git commit -m "Update ${MIRRORED_REPO}'s mirrored files"

# push the changes
git push

# open a PR
set +e # to allow EOF not to exit 1
read -r -d '' BODY <<EOF
The following files were modified:

$FILE_LIST
EOF

gh pr create \
  --title "Dependadoc PR from $MIRRORED_REPO (source ./$MIRRORED_FOLDER)" \
  --body $BODY \
  --fill