# MECI ERP V1 Online

Bản MVP mới bằng Next.js + Supabase, kế thừa dữ liệu V8/V9/V10.

## Chức năng đã có

- Dashboard điều hành
- Công trình là trung tâm
- Hạng mục theo 3 nhóm cố định: Khảo sát, Lắp đặt, Công việc khác
- Lịch làm việc
- Nhân sự theo công trình
- Hoàn thành nhanh bằng nút ✓
- Nhập JSON từ V8/V9/V10
- Xuất bản sao lưu JSON
- Đăng nhập Supabase
- Giao diện máy tính và điện thoại
- Chạy cục bộ nếu chưa cấu hình Supabase

## Triển khai

1. Tạo project Supabase.
2. Mở SQL Editor và chạy `supabase/schema.sql`.
3. Trong Authentication > Users, tạo tài khoản quản trị.
4. Sao chép `.env.example` thành `.env.local` và điền URL + anon key.
5. Đưa toàn bộ mã nguồn lên GitHub.
6. Vercel > Add New Project > Import repository.
7. Thêm 2 Environment Variables giống `.env.local`.
8. Deploy.

## Chuyển dữ liệu cũ

V9/V10 > Báo cáo > Xuất JSON.

MECI ERP V1 > Dữ liệu > Nhập JSON.
