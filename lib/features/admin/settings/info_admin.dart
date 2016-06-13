import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_application_1/core/widgets/custom_app_bar.dart';

class InfoAdminPageContent extends StatefulWidget {
  const InfoAdminPageContent({super.key});

  @override
  State<InfoAdminPageContent> createState() => _InfoAdminPageContentState();
}

class _InfoAdminPageContentState extends State<InfoAdminPageContent> {
  String _selectedTab = 'OPERASIONAL';

  final List<Map<String, dynamic>> _pusatInformasi = [
    {
      'icon': HugeIcons.strokeRoundedNotification02,
      'title': 'Notifikasi',
      'color': Colors.pink
    },
    {
      'icon': HugeIcons.strokeRoundedUserGroup,
      'title': 'Struktur Organisasi',
      'color': Colors.deepOrange
    },
    {
      'icon': HugeIcons.strokeRoundedUserShield01,
      'title': 'Admin Departemen',
      'color': Colors.teal
    },
    {
      'icon': HugeIcons.strokeRoundedCalendar03,
      'title': 'Kalender Operasional',
      'color': Colors.purple
    },
    {
      'icon': HugeIcons.strokeRoundedCalendarCheckIn01,
      'title': 'Kalender Shift',
      'color': Colors.cyan
    },
    {
      'icon': HugeIcons.strokeRoundedTruck,
      'title': 'Jadwal Kendaraan',
      'color': Colors.blue
    },
    {
      'icon': HugeIcons.strokeRoundedInvoice,
      'title': 'Informasi Penggajian',
      'color': Colors.orange
    },
    {
      'icon': HugeIcons.strokeRoundedBook02,
      'title': 'Panduan Sistem',
      'color': Colors.blueGrey
    },
  ];

  final Map<String, List<Map<String, dynamic>>> _infoKantor = {
    'OPERASIONAL': [
      {
        'title': 'Panduan Absensi & Ketentuan Shift Kerja',
        'views': '5.363x dilihat',
        'time': '5 days ago'
      },
      {
        'title': 'Prosedur Penggunaan Kendaraan Operasional',
        'views': '8.826x dilihat',
        'time': '2 months ago'
      },
      {
        'title': 'Jadwal Maintenance Kendaraan Bulanan',
        'views': '7.844x dilihat',
        'time': '2 months ago'
      },
      {
        'title': 'Ketentuan Overtime & Lembur T.A. 2025',
        'views': '11.379x dilihat',
        'time': '3 months ago'
      },
    ],
    'KEUANGAN': [
      {
        'title': 'Informasi Slip Gaji Bulan Januari 2025',
        'views': '12.855x dilihat',
        'time': '1 month ago'
      },
      {
        'title': 'Prosedur Klaim Reimburse Perjalanan Dinas',
        'views': '9.234x dilihat',
        'time': '2 months ago'
      },
      {
        'title': 'Ketentuan Tunjangan & Benefit Karyawan',
        'views': '15.672x dilihat',
        'time': '3 months ago'
      },
    ],
    'KEBIJAKAN': [
      {
        'title': 'Peraturan Perusahaan Tahun 2025',
        'views': '18.234x dilihat',
        'time': '1 month ago'
      },
      {
        'title': 'SOP Keselamatan Kerja & K3',
        'views': '14.567x dilihat',
        'time': '2 months ago'
      },
      {
        'title': 'Kebijakan Cuti & Izin Karyawan',
        'views': '16.890x dilihat',
        'time': '3 months ago'
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const CustomAppBar(
        title: 'Pusat Informasi',
        showBackButton: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Manual header removed, replaced by CustomAppBar above

              // Pusat Informasi List
              Container(
                color: Colors.white,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _pusatInformasi.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: Colors.grey.shade200,
                    indent: 16,
                    endIndent: 16,
                  ),
                  itemBuilder: (context, index) {
                    final item = _pusatInformasi[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      leading: HugeIcon(
                        icon: item['icon'],
                        color: item['color'],
                        size: 24.0,
                      ),
                      title: Text(
                        item['title'],
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF1E293B),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      trailing: HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowRight01,
                        color: Colors.grey.shade400,
                        size: 20.0,
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${item['title']} diklik')),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Info Kantor Header
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Info Kantor',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Info Kantor Content
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    // Tab Navigation
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: _infoKantor.keys.map((tab) {
                          final isSelected = _selectedTab == tab;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedTab = tab),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.blue
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  tab,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // Info List
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _infoKantor[_selectedTab]!.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: Colors.grey.shade200,
                      ),
                      itemBuilder: (context, index) {
                        final item = _infoKantor[_selectedTab]![index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _selectedTab,
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          title: Text(
                            item['title'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1E293B),
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Row(
                              children: [
                                Text(
                                  item['views'],
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: Text(
                                    '•',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                Text(
                                  item['time'],
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          trailing: Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedDoc02,
                              color: Colors.grey.shade400,
                              size: 26.0,
                            ),
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${item['title']} diklik'),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
