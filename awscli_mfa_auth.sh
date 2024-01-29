#!/bin/bash
# 参考記事 https://qiita.com/mizue/items/8292a1ea39d31a0d43bf
echo "MFA Code:"
read mfacode
# MFAクレデンシャル情報取得
SESSION_JSON=$(aws --profile $1 sts get-session-token --serial-number arn:aws:iam::$2:mfa/$3 --token-code $mfacode --output json)
if [ $? -ne 0 ]; then
    exit 1
fi

# jqで必要な項目を変数にセットする
MFA_ACCESS_KEY=$(echo $SESSION_JSON | jq -r '.Credentials.AccessKeyId')
MFA_SECRET_ACCESS_KEY=$(echo $SESSION_JSON | jq -r '.Credentials.SecretAccessKey')
MFA_SESSION_TOKEN=$(echo $SESSION_JSON | jq -r '.Credentials.SessionToken')
MFA_EXPIRATION=$(echo $SESSION_JSON | jq -r '.Credentials.Expiration')

# MFA用クレデンシャルをセットするプロファイル名
MFA_PROFILE_NAME=$1-mfa

# MFA用プロファイルにクレデンシャルをセット
aws --profile $MFA_PROFILE_NAME configure set aws_access_key_id $MFA_ACCESS_KEY
aws --profile $MFA_PROFILE_NAME configure set aws_secret_access_key $MFA_SECRET_ACCESS_KEY
aws --profile $MFA_PROFILE_NAME configure set aws_session_token $MFA_SESSION_TOKEN

echo "New credentials have been set successfully. (profile: $MFA_PROFILE_NAME, expiration: $MFA_EXPIRATION)"
echo "Please run this command: export AWS_PROFILE=$MFA_PROFILE_NAME"