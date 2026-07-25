MECI PROJECT MANAGER V10 ONLINE

Bản này giữ nguyên cấu trúc dữ liệu và khóa lưu V9: meci_pm_v8_clean.
Lưu ý: website HTTPS và file V9 chạy trên máy là hai địa chỉ khác nhau, nên dữ liệu trình duyệt không tự chuyển qua. Cần xuất JSON từ V9 rồi nhập vào V10 Online; dữ liệu không phải nhập lại thủ công.

KÍCH HOẠT ONLINE (LÀM MỘT LẦN)
1. Tạo dự án miễn phí tại Supabase.
2. Mở SQL Editor, chạy toàn bộ file supabase-setup.sql.
3. Vào Authentication > Users, tạo tài khoản quản trị bằng email và mật khẩu.
4. Vào Project Settings > API, sao chép Project URL và anon public key.
5. Mở config.js và điền:
   supabaseUrl: 'PROJECT_URL'
   supabaseAnonKey: 'ANON_KEY'
   publicBaseUrl: 'ĐƯỜNG_LINK_WEBSITE' (có thể để trống trước khi triển khai)
6. Đưa toàn bộ thư mục này lên Vercel, Netlify hoặc hosting HTTPS.

CHUYỂN DỮ LIỆU V9
1. Mở V9 cũ > Báo cáo > Xuất JSON.
2. Mở website V10 Online > Báo cáo > Nhập JSON và chọn file vừa xuất.
3. Đăng nhập quản trị.
4. Bấm “Đưa dữ liệu đang mở lên Online”.
5. Mở điện thoại bằng cùng đường link; dữ liệu sẽ tải từ Online.

LINK CÔNG KHAI
Thêm ?public=1 vào cuối đường link. Ví dụ:
https://ten-website.vercel.app/?public=1
Người xem không cần đăng nhập và chỉ thấy dữ liệu đã được lọc: không có SĐT, Maps, PPE, hồ sơ nội bộ và thiết bị.

CÀI TRÊN ĐIỆN THOẠI
Website phải chạy bằng HTTPS. Mở bằng Chrome/Safari và chọn “Thêm vào màn hình chính” hoặc nút “Cài ứng dụng”.
