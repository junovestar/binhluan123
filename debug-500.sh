#!/bin/bash

# Debug 500 Error Script
# Cách sử dụng: chmod +x debug-500.sh && ./debug-500.sh

echo "🔍 Debug 500 Internal Server Error"
echo "🕐 Bắt đầu: $(date)"
echo ""

# 1. Kiểm tra PM2
echo "=== 1. KIỂM TRA PM2 ==="
echo "📊 PM2 Status:"
pm2 status

echo ""
echo "📋 PM2 Logs (10 dòng cuối):"
pm2 logs binh-luan-backend --lines 10

# 2. Kiểm tra Nginx
echo ""
echo "=== 2. KIỂM TRA NGINX ==="
echo "🌐 Nginx Status:"
sudo systemctl status nginx --no-pager

echo ""
echo "📋 Nginx Error Logs (10 dòng cuối):"
sudo tail -10 /var/log/nginx/error.log

echo ""
echo "📋 Nginx Access Logs (10 dòng cuối):"
sudo tail -10 /var/log/nginx/access.log

# 3. Kiểm tra ports
echo ""
echo "=== 3. KIỂM TRA PORTS ==="
echo "🔌 Ports đang sử dụng:"
sudo netstat -tlnp | grep -E ':(80|443|3004)'

# 4. Kiểm tra file dist
echo ""
echo "=== 4. KIỂM TRA FILE DIST ==="
echo "📁 Thư mục dist:"
ls -la /var/www/binh-luan-generate/dist/ 2>/dev/null || echo "❌ Không tìm thấy thư mục dist"

echo ""
echo "📄 File index.html:"
if [ -f "/var/www/binh-luan-generate/dist/index.html" ]; then
    echo "✅ Tìm thấy index.html"
    head -5 /var/www/binh-luan-generate/dist/index.html
else
    echo "❌ Không tìm thấy index.html"
fi

# 5. Kiểm tra backend
echo ""
echo "=== 5. KIỂM TRA BACKEND ==="
echo "🔍 Test backend localhost:3004:"
curl -s -o /dev/null -w "Backend: %{http_code}\n" http://localhost:3004/health 2>/dev/null || echo "❌ Backend không phản hồi"

# 6. Kiểm tra Nginx local
echo ""
echo "=== 6. KIỂM TRA NGINX LOCAL ==="
echo "🔍 Test Nginx localhost:"
curl -s -o /dev/null -w "Nginx local: %{http_code}\n" http://localhost 2>/dev/null || echo "❌ Nginx local không phản hồi"

# 7. Kiểm tra domain
echo ""
echo "=== 7. KIỂM TRA DOMAIN ==="
echo "🌐 Test domain: tomtat.thanhpn.online"
curl -s -o /dev/null -w "Domain: %{http_code}\n" http://tomtat.thanhpn.online 2>/dev/null || echo "❌ Domain không phản hồi"

# 8. Restart services
echo ""
echo "=== 8. RESTART SERVICES ==="
echo "🔄 Restart backend..."
pm2 restart binh-luan-backend

echo "🔄 Restart Nginx..."
sudo systemctl restart nginx

# 9. Test lại sau restart
echo ""
echo "=== 9. TEST SAU RESTART ==="
sleep 3

echo "🔍 Test backend sau restart:"
curl -s -o /dev/null -w "Backend: %{http_code}\n" http://localhost:3004/health 2>/dev/null || echo "❌ Backend không phản hồi"

echo "🌐 Test domain sau restart:"
curl -s -o /dev/null -w "Domain: %{http_code}\n" http://tomtat.thanhpn.online 2>/dev/null || echo "❌ Domain không phản hồi"

echo ""
echo "✅ Debug hoàn thành! Thời gian: $(date)"
