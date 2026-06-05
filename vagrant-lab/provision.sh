#!/bin/bash
set -e

echo "==> Atualizando pacotes base..."
dnf clean all
dnf makecache

echo "==> Instalando Apache..."
dnf install -y httpd

echo "==> Removendo página de teste do Apache..."
rm -f /etc/httpd/conf.d/welcome.conf

echo "==> Configurando SELinux para permissivo..."
setenforce 0 || true
sed -i 's/^SELINUX=.*/SELINUX=permissive/' /etc/selinux/config

echo "==> Ajustando permissões da aplicação..."
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

echo "==> Habilitando e iniciando Apache..."
systemctl enable httpd
systemctl start httpd

if ! systemctl is-active --quiet httpd; then
  echo "ERRO: Apache não iniciou."
  journalctl -u httpd --no-pager -n 20
  exit 1
fi

echo "==> Configurando Firewall..."
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --permanent --add-service=http
firewall-cmd --reload

echo "==> Verificando arquivos da aplicação em /var/www/html..."
ls -lah /var/www/html

echo "==> Testando resposta HTTP do Apache internamente..."
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://localhost

if curl -s http://localhost | grep -q "</html>"; then
  echo "==> Aplicacao no ar! Acesse pelo host: http://localhost:8080"
else
  echo "AVISO: Verifique se index.html existe em ./html"
fi