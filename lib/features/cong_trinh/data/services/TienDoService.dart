import '../models/TienDoCongTrinhModel.dart';
import '../respositories/TienDoRepository.dart';

class TienDoService {
  final TienDoRepository repo;
  TienDoService(this.repo);
  Future<List<TienDoCongTrinhModel>> getList(int idCongTrinh) {
    return repo.getByCongTrinh(idCongTrinh);
  }
  Future<void> save(TienDoCongTrinhModel model) async {
    if (model.id == null) {
      await repo.insert(model);
    } else {
      await repo.update(model);
    }
  }
  Future<void> delete(int id) async {
    await repo.delete(id);
  }
  Future<double> tinhTienDoCongTrinh(int idCongTrinh) async{
    return await repo.tinhTienDoCongTrinh(idCongTrinh);
  }
}