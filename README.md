# Hệ thống Quản lý Danh mục Điện tử - Nông nghiệp & Môi trường

## Tổng quan

Đây là ứng dụng Flutter được thiết kế để quản lý danh mục điện tử dùng chung cho ngành Nông nghiệp và Môi trường. Hệ thống cung cấp các chức năng quản lý sản phẩm, theo dõi dữ liệu môi trường, và báo cáo thống kê.

## Tính năng chính

### 🏠 Trang chủ (Dashboard)
- Tổng quan thống kê sản phẩm
- Giám sát dữ liệu môi trường trực tiếp
- Hiển thị danh mục sản phẩm
- Sản phẩm gần đây

### 📦 Quản lý Sản phẩm
- Thêm, sửa, xóa sản phẩm
- Tìm kiếm và lọc sản phẩm theo danh mục
- Quản lý thông tin chi tiết sản phẩm
- Theo dõi tồn kho và giá cả

### 🏷️ Quản lý Danh mục
- Phân loại sản phẩm theo loại
- Hỗ trợ danh mục con
- Quản lý icon và màu sắc cho từng danh mục

### 📊 Báo cáo & Thống kê
- Biểu đồ xu hướng sản phẩm
- Phân bố theo danh mục
- Thống kê dữ liệu môi trường
- Báo cáo tổng quan

### ⚙️ Cài đặt
- Quản lý thông tin người dùng
- Cài đặt thông báo
- Cấu hình giám sát môi trường
- Thông tin ứng dụng

## Cấu trúc dự án

```
lib/
├── models/              # Các model dữ liệu
│   ├── product.dart
│   ├── category.dart
│   └── environmental_data.dart
├── providers/           # State management
│   ├── product_provider.dart
│   └── category_provider.dart
├── screens/             # Các màn hình
│   ├── main_screen.dart
│   ├── home_screen.dart
│   ├── products_screen.dart
│   ├── add_product_screen.dart
│   ├── categories_screen.dart
│   ├── reports_screen.dart
│   └── settings_screen.dart
├── widgets/             # Các widget tái sử dụng
│   ├── dashboard_card.dart
│   ├── category_grid.dart
│   ├── recent_products.dart
│   ├── environmental_monitor.dart
│   └── product_card.dart
└── main.dart           # Entry point
```

## Công nghệ sử dụng

- **Flutter**: Framework phát triển ứng dụng di động
- **Provider**: State management
- **Google Fonts**: Typography
- **FL Chart**: Biểu đồ và thống kê
- **Shared Preferences**: Lưu trữ dữ liệu local
- **HTTP**: API communication
- **Image Picker**: Quản lý hình ảnh

## Cài đặt và chạy

1. Clone repository:
```bash
git clone <repository-url>
cd enviro_agri_manager
```

2. Cài đặt dependencies:
```bash
flutter pub get
```

3. Chạy ứng dụng:
```bash
flutter run
```

## Cấu hình

### Dependencies chính:
- `provider: ^6.1.2` - State management
- `google_fonts: ^6.2.1` - Typography
- `fl_chart: ^0.69.0` - Charts và graphs
- `shared_preferences: ^2.3.2` - Local storage
- `http: ^1.2.2` - HTTP requests
- `image_picker: ^1.1.2` - Image handling
- `intl: ^0.19.0` - Internationalization

## Tính năng môi trường

Hệ thống tích hợp theo dõi các yếu tố môi trường:
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
2. Nhấn nút "+" hoặc "Thêm sản phẩm"
3. Điền thông tin chi tiết
4. Lưu sản phẩm

### Quản lý danh mục:
1. Vào màn hình "Danh mục"
2. Xem danh sách danh mục hiện có
3. Thêm/sửa/xóa danh mục theo nhu cầu

### Xem báo cáo:
1. Vào màn hình "Báo cáo"
2. Chọn kỳ báo cáo (tuần/tháng/quý/năm)
3. Xem các biểu đồ và thống kê

## Đóng góp

Mọi đóng góp đều được chào đón! Vui lòng:
1. Fork repository
2. Tạo feature branch
3. Commit changes
4. Tạo Pull Request

## License

Dự án được phát triển cho mục đích nghiên cứu và học tập.