import 'dart:io';

import 'package:flutter/material.dart';

import '../../data/models/NhatKy.dart';
import '../../data/services/nhat_ky_service.dart';
import '../../widgets/weather_dropdown.dart';

class NhatKyDetailDesktop extends StatelessWidget {
  final NhatKy nhatKy;

  NhatKyDetailDesktop({
    super.key,
    required this.nhatKy,
  });

  final _nhatKyService = NhatKyService();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xfff5f6f8),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),

            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                child: _buildContent(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.menu_book_outlined,
            color: Colors.blue.shade700,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Chi tiết nhật ký",
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff263238),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                nhatKy.tenNhatKy ?? "Chưa đặt tên",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        OutlinedButton.icon(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            size: 18,
          ),
          label: const Text("Quay lại"),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 900) {
              return Column(
                children: [
                  _buildInformationCard(),
                  const SizedBox(height: 18),
                  _buildImageCard(context),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: _buildInformationCard(),
                ),

                const SizedBox(width: 18),

                Expanded(
                  flex: 6,
                  child: _buildImageCard(context),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 18),

        _buildContentCard(),
      ],
    );
  }

  // ============================================================
  // INFORMATION
  // ============================================================

  Widget _buildInformationCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.info_outline,
            "Thông tin nhật ký",
          ),

          const SizedBox(height: 22),

          _infoItem(
            icon: Icons.calendar_today_outlined,
            label: "Ngày triển khai",
            value: nhatKy.ngayTrienKhai ?? "-",
            valueColor: Colors.redAccent,
          ),

          const SizedBox(height: 18),

          _weatherItem(
            icon: Icons.wb_sunny_outlined,
            label: "Thời tiết sáng",
            weather: nhatKy.thoiTietSang,
          ),

          const SizedBox(height: 18),

          _weatherItem(
            icon: Icons.cloud_outlined,
            label: "Thời tiết chiều",
            weather: nhatKy.thoiTietChieu,
          ),
        ],
      ),
    );
  }

  Widget _infoItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _iconBox(
          icon,
          color: valueColor ?? Colors.blue,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ??
                      const Color(0xff263238),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _weatherItem({
    required IconData icon,
    required String label,
    required int? weather,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _iconBox(
          icon,
          color: Colors.orange,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 4),

              buildWeatherInfo(
                "",
                weather,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // IMAGE
  // ============================================================

  Widget _buildImageCard(BuildContext context) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.photo_library_outlined,
            "Hình ảnh",
          ),

          const SizedBox(height: 18),

          _buildImageGrid(context),
        ],
      ),
    );
  }

  Widget _buildImageGrid(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _nhatKyService.getImages(nhatKy.id!),

      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const SizedBox(
            height: 220,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return _emptyImage(
            icon: Icons.error_outline,
            title: "Không thể tải hình ảnh",
            subtitle: "${snapshot.error}",
          );
        }

        final paths = snapshot.data ?? [];

        if (paths.isEmpty) {
          return _emptyImage(
            icon: Icons.image_not_supported_outlined,
            title: "Chưa có hình ảnh",
            subtitle:
            "Nhật ký này chưa có hình ảnh đính kèm",
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount =
            constraints.maxWidth > 900
                ? 3
                : constraints.maxWidth > 500
                ? 2
                : 1;

            return GridView.builder(
              itemCount: paths.length,

              shrinkWrap: true,

              physics:
              const NeverScrollableScrollPhysics(),

              gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.35,
              ),

              itemBuilder: (context, index) {
                return _buildImageItem(
                  context,
                  paths,
                  index,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildImageItem(
      BuildContext context,
      List<String> paths,
      int index,
      ) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        borderRadius: BorderRadius.circular(10),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _FullScreenImage(
                images: paths,
                initialIndex: index,
              ),
            ),
          );
        },

        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),

          child: Stack(
            fit: StackFit.expand,

            children: [
              Image.file(
                File(paths[index]),
                fit: BoxFit.cover,

                errorBuilder:
                    (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.broken_image_outlined,
                      size: 40,
                    ),
                  );
                },
              ),

              Positioned(
                right: 8,
                bottom: 8,

                child: Container(
                  padding: const EdgeInsets.all(6),

                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius:
                    BorderRadius.circular(6),
                  ),

                  child: const Icon(
                    Icons.zoom_in,
                    color: Colors.white,
                    size: 17,
                  ),
                ),
              ),

              Positioned(
                left: 8,
                bottom: 8,

                child: Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius:
                    BorderRadius.circular(5),
                  ),

                  child: Text(
                    "${index + 1}/${paths.length}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyImage({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      height: 220,
      width: double.infinity,

      decoration: BoxDecoration(
        color: const Color(0xfffafafa),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),

      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,

        children: [
          Icon(
            icon,
            size: 42,
            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 12),

          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContentCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.notes_outlined,
            "Nội dung nhật ký",
          ),

          const SizedBox(height: 18),

          Container(
            width: double.infinity,

            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: const Color(0xfffafafa),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.shade200,
              ),
            ),

            child: Text(
              nhatKy.noiDung?.trim().isNotEmpty == true
                  ? nhatKy.noiDung!
                  : "Chưa có nội dung",
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color:
                nhatKy.noiDung?.trim().isNotEmpty == true
                    ? const Color(0xff37474f)
                    : Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COMMON
  // ============================================================

  Widget _card({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),

      child: child,
    );
  }

  Widget _sectionTitle(
      IconData icon,
      String title,
      ) {
    return Row(
      children: [
        _iconBox(
          icon,
          color: Colors.blue,
        ),

        const SizedBox(width: 10),

        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xff263238),
          ),
        ),
      ],
    );
  }

  Widget _iconBox(
      IconData icon, {
        Color color = Colors.blue,
      }) {
    return Container(
      width: 34,
      height: 34,

      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),

      child: Icon(
        icon,
        size: 18,
        color: color,
      ),
    );
  }
}

// ============================================================
// FULL SCREEN IMAGE
// ============================================================

class _FullScreenImage extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullScreenImage({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_FullScreenImage> createState() =>
      _FullScreenImageState();
}

class _FullScreenImageState
    extends State<_FullScreenImage> {
  late PageController _controller;

  late int _currentIndex;

  @override
  void initState() {
    super.initState();

    _currentIndex =
        widget.initialIndex;

    _controller = PageController(
      initialPage: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,

        title: Text(
          "${_currentIndex + 1}/${widget.images.length}",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      ),

      body: PageView.builder(
        controller: _controller,

        itemCount: widget.images.length,

        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4,

            child: Center(
              child: Image.file(
                File(widget.images[index]),
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
}