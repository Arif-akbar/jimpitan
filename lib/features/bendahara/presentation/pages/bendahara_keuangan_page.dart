import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jimpitan_digital/core/constants/app_colors.dart';
import 'package:jimpitan_digital/shared/widgets/jimpitan_app_bar.dart';
import 'package:jimpitan_digital/shared/models/keuangan_model.dart';
import 'package:jimpitan_digital/features/bendahara/presentation/providers/keuangan_notifier.dart';

class BendaharaKeuanganPage extends ConsumerStatefulWidget {
  const BendaharaKeuanganPage({super.key});

  @override
  ConsumerState<BendaharaKeuanganPage> createState() => _BendaharaKeuanganPageState();
}

class _BendaharaKeuanganPageState extends ConsumerState<BendaharaKeuanganPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(keuanganNotifierProvider);
    final pemasukan = list.where((k) => k.tipe == TipeKeuangan.pemasukan).toList();
    final pengeluaran = list.where((k) => k.tipe == TipeKeuangan.pengeluaran).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const JimpitanAppBar(
        title: 'Arus Kas Bulanan',
        role: 'Bendahara',
        roleColor: AppColors.bendaharaColor,
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.success,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.success,
              tabs: const [
                Tab(text: 'Pemasukan'),
                Tab(text: 'Pengeluaran'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList(pemasukan, AppColors.success),
                _buildList(pengeluaran, AppColors.error),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.bendaharaColor,
        onPressed: () => _tampilkanDialogTambah(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildList(List<KeuanganModel> list, Color highlightColor) {
    if (list.isEmpty) {
       return const Center(child: Text('Belum ada catatan.', style: TextStyle(color: AppColors.textSecondary)));
    }

    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, i) {
        final item = list[i];
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
             color: AppColors.surface,
             borderRadius: BorderRadius.circular(12),
             border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 4, right: 12),
                width: 12, height: 12,
                decoration: BoxDecoration(color: highlightColor, shape: BoxShape.circle),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.keterangan,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 15),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormat('dd MMM yyyy, HH:mm').format(item.tanggal),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
               Text(
                 (item.tipe == TipeKeuangan.pemasukan ? '+' : '-') + formatter.format(item.nominal),
                 style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: highlightColor,
                    fontSize: 15,
                 ),
               ),
            ],
          ),
        );
      },
    );
  }

  void _tampilkanDialogTambah(BuildContext context) {
    TipeKeuangan selectedTipe = TipeKeuangan.pemasukan;
    final nominalCtrl = TextEditingController();
    final ketCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateBuilder) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 20, right: 20, top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Pencatatan Baru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                SegmentedButton<TipeKeuangan>(
                  segments: const [
                    ButtonSegment(value: TipeKeuangan.pemasukan, label: Text('Pemasukan')),
                    ButtonSegment(value: TipeKeuangan.pengeluaran, label: Text('Pengeluaran')),
                  ],
                  selected: {selectedTipe},
                  onSelectionChanged: (set) => setStateBuilder(() => selectedTipe = set.first),
                ),
                
                const SizedBox(height: 16),
                TextField(
                  controller: nominalCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Nominal (Rp)', prefixText: 'Rp '),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ketCtrl,
                  decoration: const InputDecoration(labelText: 'Keterangan'),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    final nominal = int.tryParse(nominalCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                    if (nominal > 0 && ketCtrl.text.isNotEmpty) {
                       ref.read(keuanganNotifierProvider.notifier).addCatatan(selectedTipe, nominal, ketCtrl.text);
                       Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bendaharaColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14)
                  ),
                  child: const Text('Simpan'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        }
      ),
    );
  }
}
