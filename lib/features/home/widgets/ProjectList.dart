import 'package:flutter/material.dart';
import '../../../data/models/CongTrinh.dart';
import '../../../services/cong_trinh_service.dart';
import '_SectionHeader.dart';

class ProjectList extends StatefulWidget {
  const ProjectList({super.key});

  @override
  State<ProjectList> createState() => _ProjectListState();
}

class _ProjectListState extends State<ProjectList> {
  List<CongTrinh> projects = [];
  bool isLoading = true;
  final _service = CongTrinhService();

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() => isLoading = true);
    try {
      final result = await _service.getDanhSachCongTrinh();
      setState(() => projects = result.take(3).toList()); // giữ nguyên kiểu List<CongTrinh>
    } catch (e) {
      print('Lỗi load dự án: $e');
      setState(() => projects = []);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(title: 'Dự án', onViewAll: () {}),
        const SizedBox(height: 8),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (projects.isEmpty)
          const Text('Không có dự án nào')
        else
          ...projects.map((p) => _ProjectItem(
            name: p.ten,
            progress: 1,
            updatedAt: p.ngayBatDau!.toString(),
            progressColor: Theme.of(context).colorScheme.secondary,
          )),
      ],
    );
  }
}

class _ProjectItem extends StatelessWidget {
  final String name;
  final double progress;
  final String updatedAt;
  final Color progressColor;
  const _ProjectItem({
    required this.name,
    required this.progress,
    required this.updatedAt,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                ),
                child: Icon(Icons.apartment,
                    color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade300,
                        color: progressColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('Cập nhật: $updatedAt',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
