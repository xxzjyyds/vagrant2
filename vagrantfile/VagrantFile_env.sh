#!/bin/bash
##############################
# date: 2024-06-06
# auther: xxzjyyds
##############################

FILE_PATH="configuration.php"

MYSQL_USER_NAME=${MYSQL_USER_NAME}
MYSQL_USER_PASSWORD=${MYSQL_USER_PASSWORD}
MYSQL_DATABASE=${MYSQL_DATABASE}
MYSQL_IP_ADDRESS=${MYSQL_IP_ADDRESS}


#修改文件上传大小
sed -i "s/ 100 \* 1024 \* 1024, \/\/ 100MB/ 20 \* 1024 \* 1024 \* 1024, \/\/ 20GB/g" $FILE_PATH

# 检查四个环境变量是否都不为空
if [[ -n "$MYSQL_USER_NAME" && -n "$MYSQL_USER_PASSWORD" && -n "$MYSQL_DATABASE" && -n "$MYSQL_IP_ADDRESS" ]]; then
   sed -i "s/\\\Filegator\\\Services\\\Auth\\\Adapters\\\JsonFile/\\\Filegator\\\Services\\\Auth\\\Adapters\\\Database/g" $FILE_PATH
   sed -i "s/'file' => __DIR__\.'\/private\/users.json',/'driver' => 'mysqli',\n        'host' => 'localhost',\n        'username' => 'root',\n        'password' => 'password',\n        'database' => 'filegator',/g" $FILE_PATH
fi
