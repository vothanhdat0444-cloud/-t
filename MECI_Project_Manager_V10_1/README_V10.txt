MECI PROJECT MANAGER V10 - ONLINE/LAN + PWA

1. GIỮ DỮ LIỆU V9
- V10 tiếp tục dùng đúng khóa localStorage: meci_pm_v8_clean.
- Khi mở V10 trên cùng trình duyệt và cùng địa chỉ file/website, dữ liệu V9 vẫn còn.
- Trước khi tải dữ liệu từ máy chủ về, V10 tự tạo một bản sao trong trình duyệt.

2. CHẠY TRÊN MÁY TÍNH
- Cài Node.js LTS.
- Giải nén thư mục này ra vị trí cố định.
- Nhấp đúp start-v10.bat.
- Mở http://localhost:8080

3. XEM TRÊN ĐIỆN THOẠI CÙNG WIFI
- Trên Windows mở CMD và gõ: ipconfig
- Lấy IPv4 của máy tính, ví dụ 192.168.1.20.
- Điện thoại mở: http://192.168.1.20:8080
- Cho phép Node.js qua Windows Firewall nếu được hỏi.
- Máy tính phải đang mở và chạy start-v10.bat.

4. CHUYỂN DỮ LIỆU V9 LÊN DÙNG CHUNG
- Trên máy tính đang có dữ liệu V9, mở V10.
- Vào Báo cáo > Đồng bộ máy tính và điện thoại.
- Bấm “Đẩy dữ liệu V9/V10 lên hệ thống”.
- Trên điện thoại bấm “Tải dữ liệu chung về máy” hoặc “Đồng bộ”.

5. CÀI NHƯ ỨNG DỤNG
- Android Chrome: menu > Thêm vào màn hình chính/Cài đặt ứng dụng.
- iPhone Safari: Chia sẻ > Thêm vào MH chính.

6. ĐƯA LÊN INTERNET
- Có thể triển khai thư mục này lên Render/Railway/VPS vì server chỉ dùng Node.js chuẩn.
- Lệnh chạy: node server.js
- Có thể đặt biến môi trường MECI_SYNC_KEY để yêu cầu khóa đồng bộ.
- PORT được lấy tự động từ môi trường hosting.

LƯU Ý
- data/cloud-data.json là cơ sở dữ liệu dùng chung. Hãy sao lưu thư mục data định kỳ.
- Đây là bản đồng bộ một cơ sở dữ liệu chung, chưa có tài khoản và phân quyền người dùng.
