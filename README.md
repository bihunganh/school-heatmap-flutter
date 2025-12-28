# Báo cáo Bài tập: Ứng dụng "Bản đồ nhiệt Sân trường" (Schoolyard Heatmap)
## Sinh viên thực hiện: Lê Mạnh Hùng Anh Mã sinh viên: 2251061698 Công nghệ sử dụng: Flutter, Sensor Fusion Logic, File I/O.

1. Tổng quan & Giải pháp Kỹ thuật
** Do hạn chế về phần cứng (Laptop cá nhân 4GB RAM không thể chạy Android Emulator mượt mà và thiếu thiết bị Android vật lý để test cảm biến), em đã triển khai giải pháp kỹ thuật "Môi trường Giả lập Cảm biến" (Sensor Simulation Environment) để hoàn thành bài tập này **
``Cơ chế hoạt động của phiên bản này:``
- Thay vì chỉ phụ thuộc vào cảm biến vật lý (thứ không tồn tại trên Laptop/Web), em đã viết thêm logic Simulation Mode trong code:
- Tự động phát hiện môi trường: Ứng dụng kiểm tra Platform. Nếu đang chạy trên Web (Project IDX) hoặc Windows, ứng dụng sẽ tự động kích hoạt chế độ Giả lập.
- Mock Data Input: Thay vì đọc stream từ cảm biến, giao diện sẽ hiển thị các thanh trượt (Sliders) cho phép người dùng nhập các thông số môi trường (Ánh sáng, Gia tốc, Từ trường) dựa trên quan sát thực tế.
- Giả lập GPS: Tọa độ GPS được sinh ngẫu nhiên (Randomize) quanh một vị trí cố định để mô phỏng việc di chuyển giữa các trạm khảo sát.

Cách tiếp cận này giúp em vẫn đảm bảo thực hiện đầy đủ logic xử lý dữ liệu, lưu trữ file JSON và hiển thị bản đồ nhiệt theo đúng yêu cầu đề bài mà không bị phụ thuộc vào phần cứng.

2. Các chức năng đã thực hiện
`A. Màn hình Trạm Khảo sát (Survey Station)`
[x] Hiển thị thông số môi trường (Lux, Gia tốc, Từ trường).
[x] Chế độ Simulation: Cho phép kéo thanh trượt để giả lập thông số khi chạy trên máy tính.
[x] Nút "Ghi dữ liệu": Đóng gói dữ liệu hiện tại + Tọa độ GPS + Thời gian thực.
[x] Lưu trữ dữ liệu cục bộ (Local Storage/File System).
`B. Màn hình Bản đồ Dữ liệu (Data Map)`
[x] Đọc dữ liệu từ file lưu trữ.
[x] Hiển thị danh sách lịch sử khảo sát.
[x] Trực quan hóa (Visualization):
- Icon Mặt trời (Ánh sáng): Đổi màu cam đậm/nhạt theo độ Lux.
- Icon Người chạy (Năng động): Đổi màu đỏ đậm/nhạt theo cường độ vận động.
- Icon Nam châm (Từ trường): Đổi màu xanh đậm/nhạt theo độ lớn từ trường.

3. Quy trình Thu thập Dữ liệu (Thực tế & Giả lập)
Do không thể mang máy tính đi đo trực tiếp, em đã thực hiện quy trình sau:
- Quan sát thực địa: Em đã đi thực tế tại sân trường để quan sát các khu vực đặc trưng.
`Mapping dữ liệu:`
-Khu vực giữa sân nắng: Em giả lập độ Lux cao (>1500), độ Năng động thấp.
-Khu vực gốc cây/hành lang: Em giả lập độ Lux thấp (~200), độ Năng động trung bình.
-Khu vực sân thể thao: Em giả lập độ Năng động cao (>5 m/s²).
-Gần cột điện/kim loại: Em giả lập chỉ số Từ trường cao (>100 µT).
-Nhập liệu: Sử dụng giao diện Sliders trên Project IDX để ghi lại các quan sát trên vào ứng dụng.

4. Kết quả Phân tích (Dựa trên dữ liệu giả lập từ thực tế)
Dựa trên dữ liệu đã thu thập và hiển thị trên màn hình "Bản đồ dữ liệu", em có những nhận xét sau:
- Về Ánh sáng: Khu vực giữa sân trường có cường độ sáng cao nhất (Icon mặt trời màu cam đậm). Các khu vực dưới tán cây và hành lang có độ sáng giảm rõ rệt.
- Về độ "Năng động": Chỉ số này phản ánh đúng thực tế hành vi con người. Khu vực sân bóng và căn tin có chỉ số rung động cao, trong khi khu vực thư viện hoặc ghế đá rất "tĩnh".
- Về Từ trường: Em đã giả lập một điểm dữ liệu gần cột cờ (kim loại lớn) với chỉ số từ trường tăng vọt, thể hiện khả năng phát hiện nhiễu từ của ứng dụng.

5. Hướng dẫn chạy thử (Cho Giảng viên)
- Do ứng dụng được tối ưu cho máy cấu hình thấp, Thầy/Cô có thể chạy trực tiếp trên trình duyệt hoặc máy ảo Android:
- Mở Project trong VS Code hoặc Project IDX.
- Chạy lệnh: flutter run
- Ứng dụng sẽ hiện Sliders để test logic.