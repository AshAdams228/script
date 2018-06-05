#!bin/bash
sudo yum -y update
sudo tee >/etc/yum.repos.d/docker.repo <<-EOF
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF
sudo yum search docker-engine
sudo yum install -y docker-engine
sudo systemctl enable docker.service && systemctl start docker.service
sudo yum -y install epel-release
sudo yum -y install python-pip
sudo pip install docker-compose
sudo tee >/home/docker_project/Dockerfile <<-EOF
FROM httpd:2.4
COPY ./public-html/ /usr/local/apache2/htdocs

FROM nginx
COPY nginx.conf /etc/nginx/nginx.conf

EOF
cd /home/docker_project
sudo tee >/home/docker_project/docker-compose.yml <<-EOF
 version: '3' 
    
 services:
    apache: 
      image: httpd:2.4 
      ports: 
      - "8080:80" 
      volumes: 
      - ./src:/usr/local/apache2/htdocs 

    web: 
      image: nginx
      volumes:
       - ./mysite.template:/etc/nginx/conf.d/mysite.template
      ports: 
       - "80:80" 
      
      command: /bin/bash -c "envsubst < /etc/nginx/conf.d/mysite.template > /etc/nginx/conf.d && nginx -g 'daemon off;'"

    db: 
      image: mariadb 
      ports: 
      - "4000:4000"
EOF

docker-compose up -d
