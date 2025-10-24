# Hệ thống Quản lý Danh mục Điện tử - Nông nghiệp & Môi trường

## Tổng quan

Đây là ứng dụng Flutter được thiết kế để quản lý danh mục điện tử dùng chung cho ngành Nông nghiệp và Môi trường. Hệ thống hỗ trợ quản lý sản phẩm, danh mục, dữ liệu môi trường, vị trí, và báo cáo thống kê, giúp người dùng dễ dàng theo dõi và đồng bộ dữ liệu giữa offline và online.

## Tính năng chính

### Trang chủ
- Tổng quan thống kê sản phẩm
- Hiển thị danh mục sản phẩm
- Sản phẩm gần đây

### Quản lý Sản phẩm
- Thêm, sửa, xóa sản phẩm
- Tìm kiếm và lọc sản phẩm theo danh mục
- Quản lý thông tin chi tiết sản phẩm
- Theo dõi tồn kho và giá cả

### Quản lý Danh mục
- Phân loại sản phẩm theo loại
- Hỗ trợ danh mục con
- Quản lý icon và màu sắc cho từng danh mục

### Báo cáo & Thống kê
- Biểu đồ xu hướng sản phẩm
- Phân bố theo danh mục
- Thống kê dữ liệu môi trường
- Báo cáo tổng quan

### Cài đặt
- Thay đổi giao diện
- Tự động đồng bộ dữ liệu
- Thông tin ứng dụng

## Phân quyền người dùng
| Vai trò    | Quyền hạn          | Mô tả                                                                                                    |
| ---------- | ------------------ | ---------------------------------------------------------------------------------------------------------|
| **Admin**  | Toàn quyền         | - Quản lý tất cả dữ liệu (sản phẩm, danh mục, môi trường, vị trí)<br>- Cấp quyền cho người dùng khác<br> |
| **Editor** | Chỉnh sửa nội dung | - Thêm, sửa, xóa dữ liệu trong phạm vi được phân công<br>- Không có quyền quản lý người dùng             |
| **Viewer** | Xem dữ liệu        | - Chỉ được phép xem thông tin và báo cáo<br>- Không thể chỉnh sửa hoặc xóa dữ liệu                       |

| Quyền              |  Admin |        Editor       | Viewer |
| ------------------ | ------ | ------------------- | ------ |
| Thêm dữ liệu       |    X   |          X          |        |
| Sửa dữ liệu        |    X   |          X          |        |
| Xóa dữ liệu        |    X   |                     |        |
| Xem dữ liệu        |    X   |          X          |    X   |
| Quản lý phân quyền |    X   |                     |        |

## Cấu trúc dự án

```
├── config
│   ├── app_constants.dart
│   └── supabase_config.dart
├── local
│   ├── drift
│   │   ├── daos
│   │   │   ├── category_dao.dart
│   │   │   ├── category_dao.g.dart
│   │   │   ├── environmental_data_dao.dart
│   │   │   ├── environmental_data_dao.g.dart
│   │   │   ├── product_dao.dart
│   │   │   ├── product_dao.g.dart
│   │   │   ├── region_dao.dart
│   │   │   └── region_dao.g.dart
│   │   ├── tables
│   │   │   ├── category_table.dart
│   │   │   ├── environmental_data_table.dart
│   │   │   ├── product_table.dart
│   │   │   └── region_table.dart
│   │   ├── app_database.dart
│   │   └── app_database.g.dart
│   └── prefs
│       └── app_preferences.dart
├── models
│   ├── category_model.dart
│   ├── environmental_data_model.dart
│   ├── product_model.dart
│   ├── region_model.dart
│   └── user_role_model.dart
├── providers
│   ├── auth_provider.dart
│   ├── category_provider.dart
│   ├── connectivity_provider.dart
│   ├── environmental_data_provider.dart
│   ├── product_provider.dart
│   ├── region_provider.dart
│   └── settings_provider.dart
├── repositories
│   ├── category_repository.dart
│   ├── environmental_data_repository.dart
│   ├── product_repository.dart
│   └── region_repository.dart
├── screens
│   ├── auth_wrapper.dart
│   ├── categories_screen.dart
│   ├── environmental_screen.dart
│   ├── forgot_password_screen.dart
│   ├── login_screen.dart
│   ├── main_screen.dart
│   ├── products_screen.dart
│   ├── region_manager_screen.dart
│   ├── register_screen.dart
│   ├── reports_screen.dart
│   ├── settings_screen.dart
│   ├── simple_home_screen.dart
│   └── user_management_screen.dart
├── services
│   ├── auth_service.dart
│   ├── category_service.dart
│   ├── connectivity_service.dart
│   ├── environmental_data_service.dart
│   ├── product_service.dart
│   ├── regions_service.dart
│   └── role_service.dart
├── widgets
│   ├── category_card.dart
│   ├── category_selector.dart
│   ├── environmental_data_card.dart
│   ├── product_card.dart
│   └── role_based_widget.dart
└── main.dart
```

```scss
UI → Provider → Repository → Service (Supabase RPC)
```

## Các thư viện sử dụng

| Package                | Version | Mục đích                                      |
| ---------------------- | ------- | --------------------------------------------- |
| **flutter**            | sdk     | Framework chính                               |
| **provider**           | ^6.1.2  | State management                              |
| **shared_preferences** | ^2.3.2  | Lưu trữ dữ liệu đơn giản (theme, cài đặt,...) |
| **http**               | ^1.2.2  | Giao tiếp API                                 |
| **image_picker**       | ^1.1.2  | Chọn hình ảnh từ camera/gallery               |
| **intl**               | ^0.20.2 | Xử lý định dạng ngày giờ, số,...              |
| **fl_chart**           | ^1.1.1  | Hiển thị biểu đồ thống kê                     |
| **supabase_flutter**   | ^2.10.3 | Backend realtime & authentication             |
| **uuid**               | ^4.5.1  | Sinh ID duy nhất                              |
| **drift**              | ^2.28.2 | ORM quản lý database SQLite                   |
| **drift_flutter**      | ^0.2.7  | Kết nối Drift với Flutter                     |
| **connectivity_plus**  | ^7.0.0  | Kiểm tra trạng thái mạng                      |


## Tính năng môi trường

- **Nhiệt độ**: Giám sát nhiệt độ môi trường
- **Độ ẩm**: Theo dõi độ ẩm không khí và đất
- **Độ pH**: Kiểm tra độ pH của đất
- **Ánh sáng**: Đo cường độ ánh sáng
- **CO2**: Theo dõi nồng độ CO2
- **Dinh dưỡng**: Nitơ, Phốt pho, Kali

## Giao diện

Ứng dụng được thiết kế với:
- **Material Design**: Giao diện hiện đại, thân thiện
- **Responsive**: Tương thích nhiều kích thước màn hình
- **Dark/Light mode**: Hỗ trợ chế độ sáng/tối
- **Intuitive UX**: Trải nghiệm người dùng trực quan

## Phát triển

### Thêm sản phẩm mới:
1. Vào màn hình "Sản phẩm"
2. Xem danh sách sản phẩm hiện có
3. Thêm/sửa/xóa sản phẩm theo nhu cầu

### Quản lý danh mục:
1. Vào màn hình "Danh mục"
2. Xem danh sách danh mục hiện có
3. Thêm/sửa/xóa danh mục theo nhu cầu

### Quản lý dữ liệu môi trường:
1. Vào màn hình "Dữ liệu môi trường"
2. Xem danh sách Dữ liệu môi trường hiện có
3. Thêm/sửa/xóa Dữ liệu môi trường theo nhu cầu

### Quản lý vị trí:
1. Vào màn hình "Vị trí"
2. Xem danh sách Vị trí hiện có
3. Thêm/sửa/xóa Vị trí theo nhu cầu

### Xem báo cáo:
1. Vào màn hình "Báo cáo"
2. Chọn kỳ báo cáo (tuần/tháng/quý/năm)
3. Xem các biểu đồ cột, tròn và thống kê

### Viết Unit Test, Widget Test, Integration Tests
- [Các file test](https://github.com/thienkk25/EnviroAgriManager/tree/main/test)

## Màn hình

<img src="assets/resultScreen/z7128852965542_003bfceb6c41b0ada257ed5ac6f57d44.jpg" width="200" height="400"> <img src="assets/resultScreen/z7128852975298_09d84fed048cdbeb371cdc55d77f7851.jpg" width="200" height="400"> <img src="assets/resultScreen/z7128852978255_87cec4a9af0f2be9b4ff3aa6c3dd9e6c.jpg" width="200" height="400"> <img src="assets/resultScreen/z7128852985022_bb5a1e43917ebbf4f571a73e286efe09.jpg" width="200" height="400"> <img src="assets/resultScreen/z7128853020463_d915f8670ed60e0343477af0bd1d0cff.jpg" width="200" height="400"> <img src="assets/resultScreen/z7128853027861_36395846b98b1021befcae3e6f9174b6.jpg" width="200" height="400"> <img src="assets/resultScreen/z7128853034565_3aa41be912ad162342d51e70adbadb88.jpg" width="200" height="400"> <img src="assets/resultScreen/z7128853034707_54c0b9fc3b58e4997b6ca31aaa05bd23.jpg" width="200" height="400"> <img src="assets/resultScreen/z7128853034277_870ef268db006078e97c7cc7c066a4a7.jpg" width="200" height="400"> <img src="assets/resultScreen/z7128853042557_b161e6b640ac1debbfc0c7e31b57d985.jpg" width="200" height="400"> <img src="assets/resultScreen/test.png" width="200" height="400">