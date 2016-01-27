LOG=/var/log/jitsi/jvb.log


if [ -f /root/.first-boot ]; then
  cp /root/samples/prosody.cfg.lua /etc/prosody/conf.avail/$DOMAIN.cfg.lua
  sed -i "s/jitsi.example.com/$DOMAIN/g" /etc/prosody/conf.avail/$DOMAIN.cfg.lua
  sed -i "s/YOURSECRET1/$YOURSECRET1/g" /etc/prosody/conf.avail/$DOMAIN.cfg.lua
  sed -i "s/YOURSECRET2/$YOURSECRET2/g" /etc/prosody/conf.avail/$DOMAIN.cfg.lua
  rm /etc/prosody/conf.d/*
  ln -s /etc/prosody/conf.avail/$DOMAIN.cfg.lua /etc/prosody/conf.d/$DOMAIN.cfg.lua

  # This could be overriden via a volume
  if [ ! -f /var/lib/prosody/$DOMAIN.key ]; then
    echo 'Generating a self signed certificate'
    openssl req -new -x509 -days 365 -nodes -subj "/C=US/ST=CA/L=San Francisco/O=Hipchat/CN=$DOMAIN" -out "/var/lib/prosody/$DOMAIN.crt" -newkey rsa:2048 -keyout "/var/lib/prosody/$DOMAIN.key"
  fi

  prosodyctl register focus auth.$DOMAIN $YOURSECRET3

  cp /root/samples/nginx.conf /etc/nginx/sites-available/$DOMAIN
  sed -i "s/jitsi.example.com/$DOMAIN/g" /etc/nginx/sites-available/$DOMAIN
  rm /etc/nginx/sites-enabled/*
  ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/$DOMAIN


  sed -i "/^JVB_HOST=/s/=.*/=$DOMAIN/g" /etc/jitsi/videobridge/config
  sed -i "/^JVB_HOSTNAME=/s/=.*/=$DOMAIN/g" /etc/jitsi/videobridge/config
  sed -i "/^JVB_SECRET=/s/=.*/=$YOURSECRET1/g" /etc/jitsi/videobridge/config

  sed -i "/^JICOFO_HOSTNAME=/s/=.*/=$DOMAIN/g" /etc/jitsi/jicofo/config
  sed -i "/^JICOFO_HOST=/s/=.*/=$DOMAIN/g" /etc/jitsi/jicofo/config
  sed -i "/^JICOFO_SECRET=/s/=.*/=$YOURSECRET2/g" /etc/jitsi/jicofo/config
  sed -i "/^JICOFO_AUTH_DOMAIN=/s/=.*/=auth\.$DOMAIN/g" /etc/jitsi/jicofo/config
  sed -i "/^JICOFO_AUTH_PASSWORD=/s/=.*/=$YOURSECRET3/g" /etc/jitsi/jicofo/config

  cp /root/samples/config.js /etc/jitsi/meet/$DOMAIN-config.js
  sed -i "s/jitsi.example.com/$DOMAIN/g" /etc/jitsi/meet/$DOMAIN-config.js

  rm /root/.first-boot
fi

prosodyctl restart
/etc/init.d/jitsi-videobridge start
/etc/init.d/jicofo start
/etc/init.d/nginx start

tail -f /var/log/jitsi/jvb.log