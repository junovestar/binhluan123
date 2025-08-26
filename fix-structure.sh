#!/bin/bash

# Fix Structure Script - Sửa cấu trúc dự án và lỗi build
# Cách sử dụng: chmod +x fix-structure.sh && ./fix-structure.sh

echo "🔧 Fix Structure - Binh Luan Generate By Thanh MKT"
echo "🕐 Bắt đầu: $(date)"
echo ""

# 1. Kiểm tra cấu trúc dự án
echo "=== 1. KIỂM TRA CẤU TRÚC DỰ ÁN ==="
cd ~/sinhton

echo "📁 Thư mục hiện tại: $(pwd)"
echo "📋 Files trong thư mục:"
ls -la

echo ""
echo "📄 Nội dung index.html:"
head -10 index.html

echo ""
echo "📁 Thư mục src:"
ls -la src/ 2>/dev/null || echo "❌ Không tìm thấy thư mục src"

echo ""
echo "📁 Thư mục backend:"
ls -la backend/ 2>/dev/null || echo "❌ Không tìm thấy thư mục backend"

# 2. Kiểm tra package.json
echo ""
echo "=== 2. KIỂM TRA PACKAGE.JSON ==="
if [ -f "package.json" ]; then
    echo "✅ Tìm thấy package.json"
    echo "📋 Scripts trong package.json:"
    grep -A 10 '"scripts"' package.json
else
    echo "❌ Không tìm thấy package.json"
fi

# 3. Tìm file main.jsx
echo ""
echo "=== 3. TÌM FILE MAIN.JSX ==="
find . -name "main.jsx" -type f 2>/dev/null || echo "❌ Không tìm thấy main.jsx"

# 4. Tìm file server.js
echo ""
echo "=== 4. TÌM FILE SERVER.JS ==="
find . -name "server.js" -type f 2>/dev/null || echo "❌ Không tìm thấy server.js"

# 5. Kiểm tra vite.config.js
echo ""
echo "=== 5. KIỂM TRA VITE.CONFIG.JS ==="
if [ -f "vite.config.js" ]; then
    echo "✅ Tìm thấy vite.config.js"
    echo "📋 Nội dung vite.config.js:"
    cat vite.config.js
else
    echo "❌ Không tìm thấy vite.config.js"
fi

# 6. Thử build lại
echo ""
echo "=== 6. THỬ BUILD LẠI ==="
echo "🔨 Build frontend..."
npm run build

# 7. Kiểm tra thư mục dist
echo ""
echo "=== 7. KIỂM TRA THƯ MỤC DIST ==="
if [ -d "dist" ]; then
    echo "✅ Thư mục dist tồn tại"
    echo "📋 Files trong dist:"
    ls -la dist/
else
    echo "❌ Thư mục dist không tồn tại"
fi

# 8. Tìm và khởi động backend
echo ""
echo "=== 8. TÌM VÀ KHỞI ĐỘNG BACKEND ==="
SERVER_FILE=$(find . -name "server.js" -type f 2>/dev/null | head -1)
if [ -n "$SERVER_FILE" ]; then
    echo "✅ Tìm thấy server.js: $SERVER_FILE"
    echo "🚀 Khởi động backend..."
    pm2 start "$SERVER_FILE" --name "binh-luan-backend"
    pm2 save
else
    echo "❌ Không tìm thấy server.js"
fi

# 9. Copy dist nếu có
echo ""
echo "=== 9. COPY DIST ==="
if [ -d "dist" ]; then
    echo "📋 Copy dist vào Nginx..."
    sudo mkdir -p /var/www/binh-luan-generate
    sudo cp -r dist /var/www/binh-luan-generate/
    sudo chown -R www-data:www-data /var/www/binh-luan-generate/
    sudo chmod -R 755 /var/www/binh-luan-generate/
    echo "✅ Đã copy dist"
else
    echo "❌ Không có thư mục dist để copy"
fi

# 10. Restart Nginx
echo ""
echo "=== 10. RESTART NGINX ==="
sudo systemctl restart nginx

# 11. Kiểm tra status
echo ""
echo "=== 11. KIỂM TRA STATUS ==="
sleep 3

echo "📊 PM2 Status:"
pm2 status

echo ""
echo "🔍 Test connections:"
# Test backend
curl -s -o /dev/null -w "Backend (localhost:3004): %{http_code}\n" http://localhost:3004/health 2>/dev/null || echo "❌ Backend không phản hồi"

# Test Nginx local
curl -s -o /dev/null -w "Nginx (localhost): %{http_code}\n" http://localhost 2>/dev/null || echo "❌ Nginx local không phản hồi"

# Test domain
echo "🌐 Testing domain: tomtat.thanhpn.online"
curl -s -o /dev/null -w "Domain: %{http_code}\n" http://tomtat.thanhpn.online 2>/dev/null || echo "❌ Domain không phản hồi"

echo ""
echo "✅ Fix Structure hoàn thành! Thời gian: $(date)"
