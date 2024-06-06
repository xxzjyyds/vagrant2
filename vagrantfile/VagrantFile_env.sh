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



# 检查四个环境变量是否都不为空
if [[ -n "$MYSQL_USER_NAME" && -n "$MYSQL_USER_PASSWORD" && -n "$MYSQL_DATABASE" && -n "$MYSQL_IP_ADDRESS" ]]; then
   sed -i "s/\\\Filegator\\\Services\\\Auth\\\Adapters\\\JsonFile/\\\Filegator\\\Services\\\Auth\\\Adapters\\\Database/g" $FILE_PATH
   sed -i "s/'file' => __DIR__\.'\/private\/users.json',/'driver' => 'mysqli',\n                'host' => '$MYSQL_IP_ADDRESS',\n                'username' => '$MYSQL_USER_NAME',\n                'password' => '$MYSQL_USER_PASSWORD',\n                'database' => '$MYSQL_DATABASE',/g" $FILE_PATH
fi

# 启动apache
apache2-foreground
