enum TrialStatusResult {
  valid,       // Còn hạn dùng thử
  expired,     // Đã hết hạn
  notFound,    // Admin đã xóa khỏi server (Cần đăng ký lại)
  noUserInfo,  // Chưa nhập thông tin
  noInternet,  // Mất kết nối mạng / Timeout
  locked
}