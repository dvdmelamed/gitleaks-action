#!/bin/bash

INPUT_CONFIG_PATH="$1"
REPORT_PATH="$2"
CONFIG=""


# check if a custom config have been provided
if [ -f "$GITHUB_WORKSPACE/$INPUT_CONFIG_PATH" ]; then
  CONFIG=" --config-path=$GITHUB_WORKSPACE/$INPUT_CONFIG_PATH"
fi

echo running gitleaks "$(gitleaks version) with the following command👇"

DONATE_MSG="👋 maintaining gitleaks takes a lot of work so consider sponsoring me or donating a little something\n\e[36mhttps://github.com/sponsors/zricethezav\n\e[36mhttps://www.paypal.me/zricethezav\n"

if [ "$GITHUB_EVENT_NAME" = "push" ]
then
  echo gitleaks detect --source=$GITHUB_WORKSPACE --verbose --redact --report-format json --report-path $REPORT_PATH $CONFIG
  gitleaks detect --source=$GITHUB_WORKSPACE --verbose --redact --report-format json --report-path $REPORT_PATH $CONFIG
elif [ "$GITHUB_EVENT_NAME" = "pull_request" ]
then 
  git --git-dir="$GITHUB_WORKSPACE/.git" log --left-right --cherry-pick --pretty=format:"%H" remotes/origin/$GITHUB_BASE_REF... > commit_list.txt
  echo gitleaks detect --source=$GITHUB_WORKSPACE --verbose --redact --commits-file=commit_list.txt --report-format json --report-path $REPORT_PATH $CONFIG
  CAPTURE_OUTPUT=$(gitleaks detect --source=$GITHUB_WORKSPACE --verbose --redact --commits-file=commit_list.txt --report-format json --report-path $REPORT_PATH $CONFIG)
fi

if [ $? -eq 1 ]
then
  GITLEAKS_RESULT=$(echo -e "\e[31m🛑 STOP! Gitleaks encountered leaks")
else
  GITLEAKS_RESULT=$(echo -e "\e[32m✅ SUCCESS! Your code is good to go!")
fi

echo "$GITLEAKS_RESULT"
echo "::set-output name=exitcode::$GITLEAKS_RESULT"
echo "----------------------------------"
echo "::set-output name=result::$CAPTURE_OUTPUT"
echo "----------------------------------"
echo -e $DONATE_MSG

ls $GITHUB_WORKSPACE

exit 0
