#!/bin/bash
########################################


MINECRAFT_HOME=/home/nick/revelation

#depends on phantomjs to get latest spongeforge version, sudo npm install -g phantomjs 
sponge=true 


#################################################################################


function error_check(){
  res=$1
  reason=$2
  if [[ -z $reason ]]; then echo "Failed."; exit; fi 

  if [[ $res -ne 0 ]]; then 
    echo "ERROR: Failed to complete step: $reason"
    echo
    echo "Continue? [y/N]"
    read cont 
    if [[ $cont == "y" ]]; then 
      return 0
    else 
      exit 
    fi
  fi 
}

if [[ -d $MINECRAFT_HOME/../upgrade ]]; then 
  echo "Directory already exists: $MINECRAFT_HOME/../upgrade"
  echo "Delete it? [Y/n]"
    read cont
    if [[ $cont == "n" ]]; then
      echo "exiting"
      exit
    fi
  rm -rf $MINECRAFT_HOME/../upgrade
  mkdir -p $MINECRAFT_HOME/../upgrade
fi

current=`cat $MINECRAFT_HOME/version.json | grep -oe '"packVersion": "[0-9.]*"' | grep -oe '[0-9.]*'`

res=1
src=`curl -s https://www.feed-the-beast.com/projects/ftb-revelation`
error_check $? "Check ftb website for latest version"

#echo $src > /tmp/output

latest=`echo $src | grep -oe 'FTBRevelationServer_[0-9.]*\.zip' | sort -rn | head -1 | cut -f2 -d\" | cut -f2 -d_ | sed 's/.zip//'`

if [[ $latest > $current ]]; then 
  echo "Found new version"
  pack_link=`echo $src | grep -oe 'href="/projects/[-/0-9a-z]*">FTBRevelationServer_'$latest'.zip' | grep -oe '/projects/[-/0-9a-z]*'`
  [[ ! -d $MINECRAFT_HOME/../upgrade ]] && mkdir $MINECRAFT_HOME/../upgrade
  if [[ ! -d $MINECRAFT_HOME/../upgrade ]]; then 
    echo "Failed to create tmp dir: $MINECRAFT_HOME/../upgrade"
    exit 
  fi

if [[ $sponge ]]; then
  [[ -d $MINECRAFT_HOME/../upgrade/plugins ]] && mkdir -p $MINECRAFT_HOME/../upgrade/plugins
  echo "Downloading latest spongeforge plugin..."
  spongeforge_url=`phantomjs /home/nick/scripts/spongie.js`
  error_check $? "Check spongeforge website for latest sponge plugin"
  sf_file=`echo $spongeforge_url | rev | cut -f1 -d\/ | rev`
  [[ ! -d $MINECRAFT_HOME/../upgrade/plugins ]] && mkdir $MINECRAFT_HOME/../upgrade/plugins
  wget -q $spongeforge_url -O $MINECRAFT_HOME/../upgrade/plugins/$sf_file
  error_check $? "Download spongeforge jar"
fi


  echo "Downloading pack upgrade version $latest..."
  wget -q https://www.feed-the-beast.com/$pack_link/download -O $MINECRAFT_HOME/../upgrade/FTBRevelationServer_$latest.zip
  error_check $? "Download revelation pack"  

  echo "Extracting archive..."
  cd $MINECRAFT_HOME/../upgrade
  unzip -q FTBRevelationServer_$latest.zip
  error_check $? "Unzip revelation pack"

  echo "Downloading forge..."
  forge_version=`ls $MINECRAFT_HOME/../upgrade/FTBserver-*.jar | grep -oe "[0-9.]*-[0-9.]*[0-9][0-9][0-9][0-9]" | head -1`
  wget -q http://files.minecraftforge.net/maven/net/minecraftforge/forge/$forge_version/forge-$forge_version-universal.jar -O $MINECRAFT_HOME/../upgrade/forge-$forge_version-universal.jar
  error_check $? "Download minecraftforge jar"
  ln -sf forge-$forge_version-universal.jar forge-universal.jar

  if [[ $sponge ]]; then
    echo "Downloading latest spongeforge plugin..."
    spongeforge_url=`phantomjs /home/nick/scripts/spongie.js`
    error_check $? "Check spongeforge website for latest sponge plugin"
    sf_file=`echo $spongeforge_url | rev | cut -f1 -d\/ | rev`
    [[ ! -d $MINECRAFT_HOME/../upgrade/plugins ]] && mkdir $MINECRAFT_HOME/../upgrade/plugins
    wget -q $spongeforge_url -O $MINECRAFT_HOME/../upgrade/plugins/$sf_file
    error_check $? "Download spongeforge jar"
  fi

  echo "Remove unused files..."
  rm $MINECRAFT_HOME/../upgrade/FTBRevelationServer_$latest.zip
  #[[ $sponge ]] && rm $MINECRAFT_HOME/../upgrade/FTBserver-*.jar

  echo "Processing..."
  sed -i 's/false/true/' $MINECRAFT_HOME/../upgrade/eula.txt 
  echo "  accepted eula"
  cp $MINECRAFT_HOME/server.properties $MINECRAFT_HOME/../upgrade/
  sed -i "s/$current/$latest/" $MINECRAFT_HOME/../upgrade/server.properties
  echo "  updated version in server.properties"

  echo "  finding changed configs..."
  mkdir -p $MINECRAFT_HOME/../upgrade/config_new
  for file in `diff $MINECRAFT_HOME/../upgrade/config $MINECRAFT_HOME/../upgrade_last/config | grep diff | awk '{print $2}'`; do cp $file $MINECRAFT_HOME/../upgrade/config_new/`basename $file`; done;

  echo 
  echo "Notes:"
  echo "1.4.0 -> 1.5.0 skip the libraries step, leave the old libraries"

  echo 
  echo "Upgrade $latest ready"
  echo 
  echo "Please backup, verify, then run:"
  echo "  rm -rf $MINECRAFT_HOME/mods/*"
  echo "  rm -rf $MINECRAFT_HOME/libraries/*"
  echo "  rm -rf $MINECRAFT_HOME/scripts/*"
[[ $sponge ]] && echo "  rm $MINECRAFT_HOME/plugins/spongeforge-*"
  echo "  rsync -av --exclude config --exclude config_new $MINECRAFT_HOME/../upgrade/ $MINECRAFT_HOME/"
  echo "  rsync -av $MINECRAFT_HOME/../upgrade/config_new/ $MINECRAFT_HOME/config/"
  echo "  $MINECRAFT_HOME/plugins/link.sh"
  echo "  rm -rf $MINECRAFT_HOME/../upgrade_last"
  echo "  mv $MINECRAFT_HOME/../upgrade mv $MINECRAFT_HOME/../upgrade_last"
  echo

else 
  echo "No update found $current = $latest" 
fi




