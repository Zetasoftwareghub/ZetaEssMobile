import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/core/utils.dart';

import '../../../../core/theme/app_theme.dart';
import '../../controller/holiday_notifier.dart';
/*

class HolidayCalendar extends ConsumerStatefulWidget {
  const HolidayCalendar({super.key});

  @override
  ConsumerState<HolidayCalendar> createState() => _HolidayCalendarState();
}

class _HolidayCalendarState extends ConsumerState<HolidayCalendar> {
  String? selectedRegion;
  late int year;

  @override
  void initState() {
    super.initState();
    year = DateTime.now().year;
  }

  void _loadHolidayList() {
    if (selectedRegion != null) {
      ref
          .read(holidayCalendarProvider.notifier)
          .getCalendar(year: year.toString(), region: selectedRegion!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final regionsAsync = ref.watch(holidayRegionProvider);
    final holidaysAsync = ref.watch(holidayCalendarProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFD5F2FA),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFD5F2FA),
        elevation: 0,
        title: const Text(
          'Holiday Calendar',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: Color(0xFF09A5D9),
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0E6D9B),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildYearSelector(),
          Padding(
            padding: const EdgeInsets.all(15),
            child: regionsAsync.when(
              data: (regions) {
                return DropdownButtonFormField<String>(
                  value: selectedRegion,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                  ),
                  hint: const Text('Select Region'),
                  items:
                      regions.map((e) {
                        return DropdownMenuItem<String>(
                          value: e.value,
                          child: Text(e.name ?? 'No name'),
                        );
                      }).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedRegion = val;
                    });
                    _loadHolidayList();
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text("Error: $e"),
            ),
          ),
          Expanded(
            child: holidaysAsync.when(
              data: (holidayList) {
                if (holidayList.isEmpty || selectedRegion == null) {
                  return const Center(child: Text('No holidays found'));
                }

                return ListView.builder(
                  itemCount: holidayList.length,
                  itemBuilder: (context, index) {
                    final item = holidayList[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 7,
                      ),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        border: Border.all(color: const Color(0xFF09A5D9)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.month ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Column(
                                children: [
                                  Text(
                                    item.date?.replaceAll("00:00:00", "") ?? '',
                                  ),
                                ],
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF78DE96),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(item.holidayReason ?? ''),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("No holidays found")),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearSelector() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black12)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _yearArrow(Icons.arrow_back_ios_new_rounded, -1),
            const SizedBox(width: 30),
            Text(
              year.toString(),
              style: const TextStyle(
                color: Color(0xFF0B6E96),
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 30),
            _yearArrow(Icons.arrow_forward_ios, 1),
          ],
        ),
      ),
    );
  }

  Widget _yearArrow(IconData icon, int change) {
    return InkWell(
      onTap: () {
        setState(() {
          year += change;
        });
        _loadHolidayList();
      },
      child: Icon(icon, color: const Color(0xFF3E3E3E), size: 20),
    );
  }
}
*/

class HolidayCalendar extends ConsumerStatefulWidget {
  const HolidayCalendar({super.key});

  @override
  ConsumerState<HolidayCalendar> createState() => _HolidayCalendarState();
}

class _HolidayCalendarState extends ConsumerState<HolidayCalendar> {
  String? selectedRegion;
  late int year;

  @override
  void initState() {
    super.initState();
    year = DateTime.now().year;
  }

  void _loadHolidayList() {
    if (!mounted || selectedRegion == null) return;

    if (selectedRegion != null) {
      ref
          .read(holidayCalendarProvider.notifier)
          .getCalendar(year: year.toString(), region: selectedRegion!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final regionsAsync = ref.watch(holidayRegionProvider);
    final holidaysAsync = ref.watch(holidayCalendarProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Holiday Calendar')),
      body: Column(
        children: [
          _buildFilters(regionsAsync),
          Expanded(child: _buildHolidaysList(holidaysAsync)),
        ],
      ),
    );
  }

  Widget _buildFilters(AsyncValue regionsAsync) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          _buildYearSelector(),
          const SizedBox(height: 16),
          regionsAsync.when(
            data: (regions) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Region',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedRegion,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF3B82F6),
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      prefixIcon: const Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFF64748B),
                        size: 20,
                      ),
                    ),
                    hint: const Text(
                      'Select your region',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                    ),
                    items:
                        regions
                            .map((e) {
                              return DropdownMenuItem<String>(
                                value: e.value,
                                child: Text(
                                  e.name ?? 'No name',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              );
                            })
                            .toList()
                            .cast<DropdownMenuItem<String>>(),

                    onChanged: (val) {
                      if (!mounted) return;

                      setState(() {
                        selectedRegion = val;
                      });
                      _loadHolidayList();
                    },
                  ),
                ],
              );
            },
            loading: () => Loader(),
            error:
                (e, _) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Color(0xFFEF4444),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Error loading regions",
                        style: TextStyle(color: Colors.red[700], fontSize: 14),
                      ),
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Year',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: Color(0xFF64748B),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    year.toString(),
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _yearArrow(Icons.remove, -1),
                  const SizedBox(width: 12),
                  _yearArrow(Icons.add, 1),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _yearArrow(IconData icon, int change) {
    return InkWell(
      onTap: () {
        setState(() {
          year += change;
        });
        _loadHolidayList();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _buildHolidaysList(AsyncValue holidaysAsync) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: holidaysAsync.when(
        data: (holidayList) {
          if (holidayList.isEmpty || selectedRegion == null) {
            return _buildEmptyState();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    const Text(
                      'Holidays',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${holidayList.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: holidayList.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = holidayList[index];
                    return _buildHolidayCard(item);
                  },
                ),
              ),
            ],
          );
        },
        loading: () => Loader(),
        error: (e, _) => _buildErrorState(),
      ),
    );
  }

  Widget _buildHolidayCard(dynamic item) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.month != null && item.month!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item.month!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.event_available_rounded,
                  color: Color(0xFF10B981),
                  size: 24,
                ),
              ),
              10.widthBox,
              Expanded(
                child: Text(
                  (item.holidayReason ?? 'Holiday'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              6.widthBox,
              Text(
                item.date.split(" ")[0],
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.event_busy_rounded,
              size: 48,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No holidays found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            selectedRegion == null
                ? 'Please select a region to view holidays'
                : 'No holidays available for the selected region and year',
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Color(0xFFEF4444),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Unable to load holidays',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please check your connection and try again',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';

    try {
      final cleanDate = dateString.replaceAll("00:00:00", "").trim();
      final date = DateTime.parse(cleanDate);
      final months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];

      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateString.replaceAll("00:00:00", "").trim();
    }
  }
}
