#!/usr/bin/env bash
git checkout develop
git pull

git checkout master
git pull

CURRENT_VERSION=$(xmllint --xpath "//*[local-name()='project']/*[local-name()='version']/text()" pom.xml)

git merge develop

echo "Current version: ${CURRENT_VERSION}"

echo "Is this a breaking change, new feature or bugfix?"
echo "type b for breaking change"
echo "type f for a new feature"
echo "type p for patch/bugfix/dependency update"

read CHANGE_TYPE

if [[ "${CHANGE_TYPE}" = "b" ]]
then
    echo "Breaking change"
    NEW_VERSION=$(./scripts/increment_version.sh -M ${CURRENT_VERSION})

elif [[ "${CHANGE_TYPE}" = "f" ]]
then
    echo "New feature"
    NEW_VERSION=$(./scripts/increment_version.sh -m ${CURRENT_VERSION})
elif [[ "${CHANGE_TYPE}" = "p" ]]
then
    echo "patch"
    NEW_VERSION=$(./scripts/increment_version.sh -p ${CURRENT_VERSION})
else
    echo "invalid input, the script will exit now"
    exit 1
fi

echo "New version: ${NEW_VERSION}"
mvn org.codehaus.mojo:versions-maven-plugin:set -DnewVersion=${NEW_VERSION} versions:commit
git add pom.xml
git commit -m "Release v${NEW_VERSION}"
git tag -a ${NEW_VERSION} -m "Release v${NEW_VERSION}"
git push
git push --tags

echo "prepare the next development"
git checkout develop
git pull
git merge master
mvn org.codehaus.mojo:versions-maven-plugin:set -DnextSnapshot=true versions:commit
git add pom.xml
git commit -m "Prepare for new development"
git push
git push --tags