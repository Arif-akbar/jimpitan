import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jimpitan_digital/core/constants/app_colors.dart';
import 'package:jimpitan_digital/shared/widgets/jimpitan_app_bar.dart';
import 'package:jimpitan_digital/features/bendahara/presentation/providers/bendahara_providers.dart';

class BendaharaRumahPage extends ConsumerStatefulWidget {
  const BendaharaRumahPage({super.key});

  @override
  ConsumerState<BendaharaRumahPage> createState() => _BendaharaRumahPageState();
}

class _BendaharaRumahPageState extends ConsumerState<BendaharaRumahPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final statusRumahList = ref.watch(statusRumahProvider);
    final tunggakanList = ref.watch(daftarTunggakanProvider);

    final rutins = statusRumahList.where((s) => s.isAktif).toList();
    final pasifs = statusRumahList.where((s) => !s.isAktif).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const JimpitanAppBar(
        title: 'Status Rumah',
        role: 'Bendahara',
        roleColor: AppColors.bendaharaColor,
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.bendaharaColor,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.bendaharaColor,
              tabs: const [
                Tab(text: 'Aktif'),
                Tab(text: 'Pasif'),
                Tab(text: 'Tunggakan'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList(rutins, false),
                _buildList(pasifs, false),
                _buildList(tunggakanList, true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<StatusRumahInfo> list, bool isTunggakan) {
    if (list.isEmpty) {
       return const Center(child: Text('Data tidak ditemukan', style: TextStyle(color: AppColors.textSecondary)));
    }

    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, i) {
        final info = list[i];
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
             color: AppColors.surface,
             borderRadius: BorderRadius.circular(12),
             border: Border.all(
                color: isTunggakan ? AppColors.error.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.1),
             ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                    Text(
                      info.rumah.nomorRumah,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    if (isTunggakan)
                      Text(
                        formatter.format(info.nominalTunggakan),
                        style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.error),
                      )
                    else 
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: info.isAktif ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                           info.isAktif ? 'Aktif' : 'Pasif',
                           style: TextStyle(
                              color: info.isAktif ? AppColors.success : AppColors.error,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                           ),
                        ),
                      ),
                 ],
               ),
               const SizedBox(height: 8),
               Text(info.rumah.namaKepalaKeluarga, style: const TextStyle(color: AppColors.textPrimary)),
               const SizedBox(height: 8),
               Text(
                 'Pembayaran bulan ini: ${info.totalBayarBulanIni}x\nKosong 3 bln terakhir: ${info.totalKosong3Bulan}x',
                 style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
               ),
            ],
          ),
        );
      },
    );
  }
}
