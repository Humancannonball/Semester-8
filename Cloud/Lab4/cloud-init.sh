#!/bin/bash
set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y docker.io podman git curl

systemctl enable docker
systemctl start docker

usermod -aG docker ${admin_username} || true

install -d -m 0755 /opt/lab4/apache-demo/public-html

cat >/opt/lab4/apache-demo/Dockerfile <<'EOF'
FROM httpd:2.4
COPY ./public-html/ /usr/local/apache2/htdocs/
EOF

cat >/opt/lab4/apache-demo/public-html/index.html <<'EOF'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Lab 4 Apache Demo</title>
  <style>
    body {
      margin: 0;
      min-height: 100vh;
      display: grid;
      place-items: center;
      font-family: "Trebuchet MS", sans-serif;
      background: linear-gradient(135deg, #eff6ff, #dbeafe 55%, #bfdbfe);
      color: #0f172a;
    }
    main {
      max-width: 42rem;
      margin: 2rem;
      padding: 2rem;
      border-radius: 1rem;
      background: rgba(255, 255, 255, 0.88);
      box-shadow: 0 20px 40px rgba(15, 23, 42, 0.15);
    }
    h1 {
      margin-top: 0;
      font-size: 2rem;
    }
    code {
      display: inline-block;
      margin-top: 0.75rem;
      padding: 0.25rem 0.5rem;
      border-radius: 0.5rem;
      background: #dbeafe;
    }
  </style>
</head>
<body>
  <main>
    <h1>Lab 4 container demo</h1>
    <p>This page is served from a custom Apache image prepared by cloud-init.</p>
    <p>Build it on the VM from:</p>
    <code>/opt/lab4/apache-demo</code>
  </main>
</body>
</html>
EOF

cat >/etc/motd <<'EOF'
Lab 4 VM is ready.

Docker and Podman are installed.
Sample Docker build context:
  /opt/lab4/apache-demo

Suggested commands:
  docker version
  docker run hello-world
  cd /opt/lab4/apache-demo
  docker build -t my-docker-image .
  docker run -dit --name my-container1 -p 8080:80 my-docker-image
EOF
