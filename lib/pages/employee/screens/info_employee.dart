import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class InfoEmployeePage extends StatefulWidget {
  const InfoEmployeePage({super.key});

  @override
  State<InfoEmployeePage> createState() => _InfoEmployeePageState();
}

class _InfoEmployeePageState extends State<InfoEmployeePage> {
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
    {
      'icon': HugeIcons.strokeRoundedHelpCircle,
      'title': 'Bantuan & FAQ',
      'color': Colors.green
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
      {
        'title': 'Tata Cara Pengajuan Cuti & Izin',
        'views': '9.542x dilihat',
        'time': '3 months ago'
      },
      {
        'title': 'Prosedur Pergantian Shift Darurat',
        'views': '6.721x dilihat',
        'time': '4 months ago'
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
      {
        'title': 'Cara Akses E-Payslip Online',
        'views': '8.391x dilihat',
        'time': '3 months ago'
      },
      {
        'title': 'Informasi Potongan BPJS & Pajak',
        'views': '11.208x dilihat',
        'time': '4 months ago'
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
      {
        'title': 'Kode Etik & Tata Tertib Karyawan',
        'views': '13.456x dilihat',
        'time': '3 months ago'
      },
      {
        'title': 'Prosedur Pengaduan & Whistleblowing',
        'views': '7.234x dilihat',
        'time': '5 months ago'
      },
    ],
    'PENGEMBANGAN': [
      {
        'title': 'Program Pelatihan Karyawan 2025',
        'views': '10.567x dilihat',
        'time': '2 weeks ago'
      },
      {
        'title': 'Informasi Beasiswa Pendidikan',
        'views': '8.234x dilihat',
        'time': '1 month ago'
      },
      {
        'title': 'Panduan Career Development Plan',
        'views': '12.890x dilihat',
        'time': '2 months ago'
      },
      {
        'title': 'Jadwal Training Soft Skills',
        'views': '9.456x dilihat',
        'time': '2 months ago'
      },
      {
        'title': 'Program Sertifikasi Profesi',
        'views': '7.123x dilihat',
        'time': '3 months ago'
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan padding yang aman
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Text(
                  'Pusat Informasi',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),

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
