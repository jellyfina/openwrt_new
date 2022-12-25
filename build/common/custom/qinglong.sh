#!/bin/bash
declare flag=0
clear
while [ "$flag" -eq 0 ]
do
# 青龙变量
QL_DOCKER_IMG_NAME="whyour/qinglong"
TAG="latest"
QL_PATH=""
QL_SHELL_FOLDER=$(pwd)/ql
N1_QL_FOLDER=/mnt/mmcblk2p4/ql
QL_CONTAINER_NAME=""
NETWORK="bridge"
QL_PORT="5700"
log() {
    echo -e "\n$1"
}
inp() {
    echo -e "\n$1"
}

opt() {
    echo -n -e "输入您的选择->"
}
cancelrun() {
    if [ $# -gt 0 ]; then
        echo -e " $1 "
    fi
    exit 1
}


TIME() {
[[ -z "$1" ]] && {
	echo -ne " "
} || {
     case $1 in
	r) export Color="\e[31;1m";;
	g) export Color="\e[32;1m";;
	b) export Color="\e[34;1m";;
	y) export Color="\e[33;1m";;
	z) export Color="\e[35;1m";;
	l) export Color="\e[36;1m";;
	w) export Color="\e[29;1m";;
      esac
	[[ $# -lt 2 ]] && echo -e "\e[36m\e[0m ${1}" || {
		echo -e "\e[36m\e[0m ${Color}${2}\e[0m"
	 }
      }
}
#cat << EOF
TIME w "----------------------------------------"
TIME w "|****Please Enter Your Choice:[0-2]****|"
TIME w "|**************** 青龙 ****************|"
TIME w "----------------------------------------"
TIME w "(1) linxu系统、X86的openwrt、群辉等请选择 1"
TIME w "(2) N1的EMMC上运行的openwrt请选择 2"
TIME b "(0) 退出"
#EOF
TIME r "<注>选择1或2后，如果不明白如何选择或输入，请狂按回车！"
 read -p "Please enter your choice[0-3]: " input2
 case $input2 in 
 1)
  TIME y " >>>>>>>>>>>开始安装青龙"

    input_container_ql1_info() {
    log "列出所有宿主机上的容器"
    docker ps -a
    TIME g "-----------------------------------------------------"
    TIME g "|        青龙启动需要一点点时间，请耐心等待！       |"
    sleep 10
    TIME g "|             安装完成，自动退出脚本                |"
    if [ "$NETWORK" = "host" ]; then
    		TIME g "|            访问方式为 宿主机ip:5700               |"
    elif [ "$NETWORK" = "bridge" ]; then
    		TIME g "|            访问方式为 宿主机ip:$QL_PORT               |"
    fi
    TIME g "-----------------------------------------------------"
    exit 0
    }

  # 确认
  input_container_ql1_check() {
  while true
  do
  	TIME y "青龙配置文件路径：$QL_PATH"
  	TIME y "青龙容器名：$QL_CONTAINER_NAME"
  	TIME y "青龙网络类型：$NETWORK"
    TIME y "青龙版本：$TAG"
  	if [ "$NETWORK" = "host" ]; then
  		TIME y "青龙面板端口：5700"
  	elif [ "$NETWORK" = "bridge" ]; then
  		TIME y "青龙网络请求查看端口：$QL_PORT"
  	fi
  	read -r -p "以上信息是否正确？[Y/n] " input21
  	case $input21 in
  		[yY][eE][sS]|[yY])
  			break
  			;;
  		[nN][oO]|[nN])
  			TIME w "即将返回上一步"
  			sleep 1
  			QL_PORT="5700"
            TAG="latest"
  			input_container_ql1_version
            input_container_ql1_judge
            input_container_ql1_info
  			;;
  		*)
  			TIME r "输入错误，请输入[Y/n]"
  			;;
  	esac
  done
  }

  # 版本号
  input_container_ql1_version() {
  TIME w "青龙自2.12.0开始改变了目录结构，本脚本开始提供不同青龙版本。"
  TIME w "请根据提示驶入对应内容,推荐部署2.11.3，方便与spy对接。"
  TIME w "目前提供的版本有如下："
  TIME w "2.10、2.10.6、2.10.7、2.10.8、2.10.9、2.10.10、2.10.11、2.10.12、2.10.13"
  TIME w "2.11.0、2.11.1、2.11.2、2.11.3"
  TIME w "2.12.0、2.12.1、2.12.2"
  TIME w "2.13.0、2.13.1、2.13.2和最新"
  echo -n -e "请输入版本号（回车默认为最新版本）: "
  read ql_version
  if [ -z "$ql_version" ]; then
      QL_VERSION=$TAG
  elif [ -n "$ql_version" ]; then
      QL_VERSION=$ql_version
  fi
  TAG=$QL_VERSION
  }
  input_container_ql1_version

  # 创建映射文件夹
  input_container_ql1_config1() {
  echo -n -e "请输入青龙配置文件保存的绝对路径（示例：/home/ql)，回车默认为当前目录: "
  read ql_path
  if [ -z "$ql_path" ]; then
      QL_PATH=$QL_SHELL_FOLDER
  elif [ -d "$ql_path" ]; then
      QL_PATH=$ql_path
  else
      #mkdir -p $ql_path
      QL_PATH=$ql_path
  fi
  CONFIG_PATH=$QL_PATH
  }

  # 创建映射文件夹
  input_container_ql1_config2() {
  echo -n -e "请输入青龙配置文件保存的绝对路径（示例：/home/ql)，回车默认为当前目录: "
  read ql_path
  if [ -z "$ql_path" ]; then
      QL_PATH=$QL_SHELL_FOLDER
  elif [ -d "$ql_path" ]; then
      QL_PATH=$ql_path
  else
      #mkdir -p $ql_path
      QL_PATH=$ql_path
  fi
  CONFIG_PATH=$QL_PATH/config
  DB_PATH=$QL_PATH/db
  REPO_PATH=$QL_PATH/repo
  SCRIPT_PATH=$QL_PATH/scripts
  LOG_PATH=$QL_PATH/log
  DEPS_PATH=$QL_PATH/deps
  }

  # 输入容器名
  input_container_ql1_name() {
    echo -n -e "请输入将要创建的容器名[默认为：ql]-> "
    read container_name
    if [ -z "$container_name" ]; then
        QL_CONTAINER_NAME="ql"
    else
        QL_CONTAINER_NAME=$container_name
    fi
  }

  # 网络模式
  input_container_ql1_network_config() {
  inp "请选择容器的网络类型：\n1) host\n2) bridge[默认]"
  opt
  read net
  if [ "$net" = "1" ]; then
      NETWORK="host"
      MAPPING_QL_PORT=""
  fi
  
  if [ "$NETWORK" = "bridge" ]; then
      inp "是否修改青龙端口[默认 5700]：\n1) 修改\n2) 不修改[默认]"
      opt
      read change_ql_port
      if [ "$change_ql_port" = "1" ]; then
          echo -n -e "输入想修改的端口->"
          read QL_PORT
      else
          QL_PORT="5700"
      fi
  fi
  }

  input_container_ql1_build1() {
  TIME y " >>>>>>>>>>>配置完成，开始安装青龙"
  log "1.开始创建配置文件目录"
  PATH_LIST=($CONFIG_PATH)
  for i in ${PATH_LIST[@]}; do
      mkdir -p $i
  done

  log "2.开始创建容器并执行"
  docker run -dit \
      -t \
      -v $CONFIG_PATH:/ql/data \
      -e ENABLE_HANGUP=false \
      -e ENABLE_WEB_PANEL=true \
      -p $QL_PORT:5700 \
      --name $QL_CONTAINER_NAME \
      --hostname $QL_CONTAINER_NAME \
      --restart always \
      --network $NETWORK \
      $QL_DOCKER_IMG_NAME:$TAG

      if [ $? -ne 0 ] ; then
          cancelrun "** 错误：容器创建失败，请翻译以上英文报错，Google/百度尝试解决问题！"
      fi
  }

  input_container_ql1_build2() {
  TIME y " >>>>>>>>>>>配置完成，开始安装青龙"
  log "1.开始创建配置文件目录"
  PATH_LIST=($CONFIG_PATH $DB_PATH $REPO_PATH $SCRIPT_PATH $LOG_PATH $DEPS_PATH)
  for i in ${PATH_LIST[@]}; do
      mkdir -p $i
  done

  log "2.开始创建容器并执行"
  docker run -dit \
      -t \
      -v $CONFIG_PATH:/ql/config \
      -v $DB_PATH:/ql/db \
      -v $LOG_PATH:/ql/log \
      -v $REPO_PATH:/ql/repo \
      -v $SCRIPT_PATH:/ql/scripts \
      -v $DEPS_PATH:/ql/deps \
      -e ENABLE_HANGUP=false \
      -e ENABLE_WEB_PANEL=true \
      -p $QL_PORT:5700 \
      --name $QL_CONTAINER_NAME \
      --hostname $QL_CONTAINER_NAME \
      --restart always \
      --network $NETWORK \
      $QL_DOCKER_IMG_NAME:$TAG

      if [ $? -ne 0 ] ; then
          cancelrun "** 错误：容器创建失败，请翻译以上英文报错，Google/百度尝试解决问题！"
      fi
  }

  input_container_ql1_judge() {
  if [ $TAG == latest ] || [ $TAG == "2.12" ] || [ $TAG == "2.12.0" ] || [ $TAG == "2.12.1" ] || [ $TAG == "2.12.2" ] || [ $TAG == "2.13" ] || [ $TAG == "2.13.0" ] || [ $TAG == "2.13.1" ]; then
      input_container_ql1_config1
      input_container_ql1_name
      input_container_ql1_network_config
      input_container_ql1_check
      input_container_ql1_build1
  else 
      input_container_ql1_config2
      input_container_ql1_name
      input_container_ql1_network_config
      input_container_ql1_check
      input_container_ql1_build2
  fi
  }
  input_container_ql1_judge

      log "列出所有宿主机上的容器"
      docker ps -a
    TIME g "-----------------------------------------------------"
    TIME g "|        青龙启动需要一点点时间，请耐心等待！       |"
    sleep 10
    TIME g "|             安装完成，自动退出脚本                |"
    if [ "$NETWORK" = "host" ]; then
    		TIME g "|            访问方式为 宿主机ip:5700               |"
    elif [ "$NETWORK" = "bridge" ]; then
    		TIME g "|            访问方式为 宿主机ip:$QL_PORT               |"
    fi
    TIME g "-----------------------------------------------------"
  exit 0
  ;;
 2)  
  TIME y " >>>>>>>>>>>开始安装青龙到N1的/mnt/mmcblk2p4/"

    input_container_ql2_info() {
    log "列出所有宿主机上的容器"
    docker ps -a
    TIME g "-----------------------------------------------------"
    TIME g "|        青龙启动需要一点点时间，请耐心等待！       |"
    sleep 10
    TIME g "|             安装完成，自动退出脚本                |"
    if [ "$NETWORK" = "host" ]; then
    		TIME g "|            访问方式为 宿主机ip:5700               |"
    elif [ "$NETWORK" = "bridge" ]; then
    		TIME g "|            访问方式为 宿主机ip:$QL_PORT               |"
    fi
    TIME g "-----------------------------------------------------"
    exit 0
    }

  # 确认
  input_container_ql2_check() {
  while true
  do
  	TIME y "青龙配置文件路径：$QL_PATH"
  	TIME y "青龙容器名：$QL_CONTAINER_NAME"
  	TIME y "青龙网络类型：$NETWORK"
    TIME y "青龙版本：$TAG"
  	if [ "$NETWORK" = "host" ]; then
  		TIME y "青龙面板端口：5700"
  	elif [ "$NETWORK" = "bridge" ]; then
  		TIME y "青龙网络请求查看端口：$QL_PORT"
  	fi
  	read -r -p "以上信息是否正确？[Y/n] " input21
  	case $input21 in
  		[yY][eE][sS]|[yY])
  			break
  			;;
  		[nN][oO]|[nN])
  			TIME w "即将返回上一步"
  			sleep 1
  			QL_PORT="5700"
            TAG="latest"
  			input_container_ql2_version
            input_container_ql2_judge
            input_container_ql2_info
  			;;
  		*)
  			TIME r "输入错误，请输入[Y/n]"
  			;;
  	esac
  done
  }

  # 版本号
  input_container_ql2_version() {
  TIME w "青龙自2.12.0开始改变了目录结构，本脚本开始提供不同青龙版本。"
  TIME w "请根据提示驶入对应内容。"
  TIME w "目前提供的版本有如下："
  TIME w "2.10、2.10.6、2.10.7、2.10.8、2.10.9、2.10.10、2.10.11、2.10.12、2.10.13"
  TIME w "2.11.0、2.11.1、2.11.2、2.11.3"
  TIME w "2.12.0、2.12.1、2.12.2"
  TIME w "2.13.0、2.13.1、2.13.2和最新"
  echo -n -e "请输入版本号（回车默认为最新版本）: "
  read ql_version
  if [ -z "$ql_version" ]; then
      QL_VERSION=$TAG
  elif [ -n "$ql_version" ]; then
      QL_VERSION=$ql_version
  fi
  TAG=$QL_VERSION
  }
  input_container_ql2_version


  # 创建映射文件夹
  input_container_ql2_config1() {
  echo -n -e "请输入青龙存储的文件夹名称（如：ql)，回车默认为 ql: "
  read ql_path
  if [ -z "$ql_path" ]; then
      QL_PATH=$N1_QL_FOLDER
  elif [ -d "$ql_path" ]; then
      QL_PATH=/mnt/mmcblk2p4/$ql_path
  else
      #mkdir -p /mnt/mmcblk2p4/$ql_path
      QL_PATH=/mnt/mmcblk2p4/$ql_path
  fi
  CONFIG_PATH=$QL_PATH
  }

  # 创建映射文件夹
  input_container_ql2_config2() {
  echo -n -e "请输入青龙存储的文件夹名称（如：ql)，回车默认为 ql: "
  read ql_path
  if [ -z "$ql_path" ]; then
      QL_PATH=$N1_QL_FOLDER
  elif [ -d "$ql_path" ]; then
      QL_PATH=/mnt/mmcblk2p4/$ql_path
  else
      #mkdir -p /mnt/mmcblk2p4/$ql_path
      QL_PATH=/mnt/mmcblk2p4/$ql_path
  fi
  CONFIG_PATH=$QL_PATH/config
  DB_PATH=$QL_PATH/db
  REPO_PATH=$QL_PATH/repo
  SCRIPT_PATH=$QL_PATH/scripts
  LOG_PATH=$QL_PATH/log
  DEPS_PATH=$QL_PATH/deps
  }
  
  # 输入容器名
  input_container_ql2_name() {
    echo -n -e "请输入将要创建的容器名[默认为：ql]-> "
    read container_name
    if [ -z "$container_name" ]; then
        QL_CONTAINER_NAME="ql"
    else
        QL_CONTAINER_NAME=$container_name
    fi
  }

  # 网络模式
  input_container_ql2_network_config() {
  inp "请选择容器的网络类型：\n1) host\n2) bridge[默认]"
  opt
  read net
  if [ "$net" = "1" ]; then
      NETWORK="host"
      MAPPING_QL_PORT=""
  fi
  
  if [ "$NETWORK" = "bridge" ]; then
      inp "是否修改青龙端口[默认 5700]：\n1) 修改\n2) 不修改[默认]"
      opt
      read change_ql_port
      if [ "$change_ql_port" = "1" ]; then
          echo -n -e "输入想修改的端口->"
          read QL_PORT
      else
          QL_PORT="5700"
      fi
  fi
  }

  input_container_ql2_build1() {
  TIME y " >>>>>>>>>>>配置完成，开始安装青龙"
  log "1.开始创建配置文件目录"
  PATH_LIST=($CONFIG_PATH $DB_PATH $REPO_PATH $SCRIPT_PATH $LOG_PATH $DEPS_PATH)
  for i in ${PATH_LIST[@]}; do
      mkdir -p $i
  done

  log "3.开始创建容器并执行"
  docker run -dit \
      -t \
      -v $CONFIG_PATH:/ql/data \
      -e ENABLE_HANGUP=false \
      -e ENABLE_WEB_PANEL=true \
      -p $QL_PORT:5700 \
      --name $QL_CONTAINER_NAME \
      --hostname $QL_CONTAINER_NAME \
      --restart always \
      --network $NETWORK \
      $QL_DOCKER_IMG_NAME:$TAG

      if [ $? -ne 0 ] ; then
          cancelrun "** 错误：容器创建失败，请翻译以上英文报错，Google/百度尝试解决问题！"
      fi
  }

  input_container_ql2_build2() {
  TIME y " >>>>>>>>>>>配置完成，开始安装青龙"
  log "1.开始创建配置文件目录"
  PATH_LIST=($CONFIG_PATH $DB_PATH $REPO_PATH $SCRIPT_PATH $LOG_PATH $DEPS_PATH)
  for i in ${PATH_LIST[@]}; do
      mkdir -p $i
  done

  log "3.开始创建容器并执行"
  docker run -dit \
      -t \
      -v $CONFIG_PATH:/ql/config \
      -v $DB_PATH:/ql/db \
      -v $LOG_PATH:/ql/log \
      -v $REPO_PATH:/ql/repo \
      -v $SCRIPT_PATH:/ql/scripts \
      -v $DEPS_PATH:/ql/deps \
      -e ENABLE_HANGUP=false \
      -e ENABLE_WEB_PANEL=true \
      -p $QL_PORT:5700 \
      --name $QL_CONTAINER_NAME \
      --hostname $QL_CONTAINER_NAME \
      --restart always \
      --network $NETWORK \
      $QL_DOCKER_IMG_NAME:$TAG

      if [ $? -ne 0 ] ; then
          cancelrun "** 错误：容器创建失败，请翻译以上英文报错，Google/百度尝试解决问题！"
      fi
  }

  input_container_ql2_judge() {
  if [ $TAG == latest ]; then
      input_container_ql2_config1
      input_container_ql2_name
      input_container_ql2_network_config
      input_container_ql2_check
      input_container_ql2_build1
  else 
      input_container_ql2_config2
      input_container_ql2_name
      input_container_ql2_network_config
      input_container_ql2_check
      input_container_ql2_build2
  fi
  }
  input_container_ql2_judge

      log "列出所有宿主机上的容器"
      docker ps -a
    TIME g "-----------------------------------------------------"
    TIME g "|        青龙启动需要一点点时间，请耐心等待！       |"
    sleep 10
    TIME g "|             安装完成，自动退出脚本                |"
    if [ "$NETWORK" = "host" ]; then
    		TIME g "|            访问方式为 宿主机ip:5700               |"
    elif [ "$NETWORK" = "bridge" ]; then
    		TIME g "|            访问方式为 宿主机ip:$QL_PORT               |"
    fi
    TIME g "-----------------------------------------------------"
  exit 0
  ;;
 0) 
 clear 
 exit
 ;;
 *) TIME r "----------------------------------"
    TIME r "|          Warning!!!            |"
    TIME r "|       请输入正确的选项!        |"
    TIME r "----------------------------------"
 for i in $(seq -w 1 -1 1)
   do
     #TIME r "\b\b$i";
     sleep 1;
   done
 clear
 ;;
 esac
 done
;;
