#!/bin/bash

# Danh sách các subdomain
SUBDOMAINS=(
    "minio"
    "harbor"
    "vault"
    "mlflow"
    "grafana"
    "argocd"
    "ciflow"
    "app-api"
    "ghtorrent-api"
    "model-api"
)

# Root domain
ROOT_DOMAIN="th1enlm02.live"

# Đường dẫn lưu trữ certificate cho HAProxy
CERTS_DIR="/etc/haproxy/certs"

# Email dùng cho Certbot
EMAIL="minhthienluu2406@gmail.com"

# Đảm bảo thư mục /etc/haproxy/certs tồn tại
if [ ! -d "$CERTS_DIR" ]; then
    echo "Creating directory $CERTS_DIR..."
    sudo mkdir -p "$CERTS_DIR"
    sudo chmod 700 "$CERTS_DIR"
fi

# Tạo danh sách các domain cho Certbot
CERTBOT_DOMAINS=""
for subdomain in "${SUBDOMAINS[@]}"; do
    CERTBOT_DOMAINS="$CERTBOT_DOMAINS -d ${subdomain}.${ROOT_DOMAIN}"
done

# Tạo certificate cho tất cả subdomain trong một lệnh
echo "Obtaining SSL certificate for all subdomains..."
for i in {1..3}; do
    if sudo certbot certonly --standalone $CERTBOT_DOMAINS --non-interactive --agree-tos -m "$EMAIL" --preferred-challenges http --http-01-port 80 --cert-name "$ROOT_DOMAIN"; then
        echo "Successfully obtained certificate for all subdomains"

        # Combine và copy certificate cho từng subdomain
        CERT_PATH="/etc/letsencrypt/live/${ROOT_DOMAIN}"
        if [ -f "$CERT_PATH/fullchain.pem" ] && [ -f "$CERT_PATH/privkey.pem" ]; then
            for subdomain in "${SUBDOMAINS[@]}"; do
                PEM_FILE="${CERTS_DIR}/${subdomain}.pem"
                echo "Combining certificate and private key into $PEM_FILE..."
                sudo cat "$CERT_PATH/fullchain.pem" "$CERT_PATH/privkey.pem" | sudo tee "$PEM_FILE" > /dev/null
                sudo chmod 600 "$PEM_FILE"
                echo "Certificate copied to $PEM_FILE"
            done
        else
            echo "Error: Certificate files not found in $CERT_PATH"
            exit 1
        fi
        break
    fi
    echo "Certbot failed, retrying ($i/3)..."
    sleep 10
done

# Kiểm tra nếu Certbot thất bại sau 3 lần
if [ $? -ne 0 ]; then
    echo "Failed to obtain certificate after 3 retries"
    exit 1
fi

# Restart HAProxy để áp dụng các certificate mới
echo "Restarting HAProxy..."
if sudo systemctl restart haproxy; then
    echo "HAProxy restarted successfully"
else
    echo "Error: Failed to restart HAProxy"
    exit 1
fi

# Stop Nginx if it's running
if systemctl is-active --quiet nginx; then
    echo "Stopping Nginx..."
    sudo systemctl stop nginx
fi

echo "SSL certificate generation and HAProxy configuration completed"