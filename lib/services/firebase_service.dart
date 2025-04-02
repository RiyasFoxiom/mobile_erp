import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum ENVIRONMENT { dev, prod }

const environment = ENVIRONMENT.dev;

get baseUrl => environment == ENVIRONMENT.dev ? "dev" : "prod";

class FirebaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      FirebaseDatabase.instance.setPersistenceEnabled(true);
      FirebaseDatabase.instance.setPersistenceCacheSizeBytes(10000000);
    } catch (e) {
      debugPrint('Error initializing Firebase: $e');
      rethrow;
    }
  }

  Future<void> saveSaleEntry(Map<String, dynamic> saleData) async {
    try {
      final now = DateTime.now();
      final year = now.year.toString();
      final month = now.month.toString().padLeft(2, '0');
      final day = now.day.toString().padLeft(2, '0');

      final saleRef = _database
          .child(baseUrl)
          .child('sales')
          .child(year)
          .child(month)
          .child(day)
          .child(saleData['invoiceNumber']);

      await saleRef.set(saleData);
      debugPrint('Sale saved successfully: ${saleData['invoiceNumber']}');
    } catch (e) {
      debugPrint('Error saving sale entry: $e');
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> getRecentSales() {
    debugPrint('Fetching recent sales...');
    return _database.child('sales').onValue.map((event) {
      if (event.snapshot.value == null) {
        debugPrint('No recent sales found');
        return [];
      }

      List<Map<String, dynamic>> sales = [];
      try {
        Map<dynamic, dynamic> years =
            event.snapshot.value as Map<dynamic, dynamic>;

        years.forEach((year, yearData) {
          if (yearData is Map) {
            yearData.forEach((month, monthData) {
              if (monthData is Map) {
                monthData.forEach((day, dayData) {
                  if (dayData is Map) {
                    dayData.forEach((invoiceNumber, saleData) {
                      if (saleData is Map) {
                        try {
                          Map<String, dynamic> cleanData = {};
                          saleData.forEach((key, value) {
                            cleanData[key.toString()] = value;
                          });
                          sales.add(cleanData);
                        } catch (e) {
                          debugPrint('Error converting specific sale: $e');
                        }
                      }
                    });
                  }
                });
              }
            });
          }
        });
      } catch (e) {
        debugPrint('Error processing sales data: $e');
      }

      sales.sort((a, b) {
        DateTime getDateTime(dynamic timestamp) {
          if (timestamp is int) {
            return DateTime.fromMillisecondsSinceEpoch(timestamp);
          } else if (timestamp is String) {
            return DateTime.parse(timestamp);
          }
          return DateTime.now();
        }

        return getDateTime(
          b['timestamp'],
        ).compareTo(getDateTime(a['timestamp']));
      });

      sales = sales.take(10).toList(); // Limit to 10 most recent sales
      debugPrint('Found ${sales.length} recent sales');
      return sales;
    });
  }

  Stream<List<Map<String, dynamic>>> getTodaySales() {
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

    debugPrint('Fetching today\'s sales for $year-$month-$day');
    return _database
        .child(baseUrl)
        .child('sales')
        .child(year)
        .child(month)
        .child(day)
        .onValue
        .map((event) {
          if (event.snapshot.value == null) {
            debugPrint('No sales found for today');
            return [];
          }

          List<Map<String, dynamic>> sales = [];
          try {
            Map<dynamic, dynamic> todaySales =
                event.snapshot.value as Map<dynamic, dynamic>;

            todaySales.forEach((invoiceNumber, saleData) {
              if (saleData is Map) {
                try {
                  Map<String, dynamic> cleanData = {};
                  saleData.forEach((key, value) {
                    cleanData[key.toString()] = value;
                  });
                  sales.add(cleanData);
                } catch (e) {
                  debugPrint(
                    'Error converting specific sale: $e, Data: $saleData',
                  );
                }
              }
            });
          } catch (e) {
            debugPrint('Error processing today\'s sales data: $e');
          }

          sales.sort((a, b) {
            DateTime getDateTime(dynamic timestamp) {
              if (timestamp is int) {
                return DateTime.fromMillisecondsSinceEpoch(timestamp);
              } else if (timestamp is String) {
                return DateTime.parse(timestamp);
              }
              return DateTime.now();
            }

            return getDateTime(
              b['timestamp'],
            ).compareTo(getDateTime(a['timestamp']));
          });

          debugPrint('Found ${sales.length} sales for today');
          return sales;
        });
  }

  Future<void> deleteSale(String invoiceNumber, DateTime date) async {
    try {
      final year = date.year.toString();
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');

      await _database
          .child(baseUrl)
          .child('sales')
          .child(year)
          .child(month)
          .child(day)
          .child(invoiceNumber)
          .remove();
      debugPrint('Sale deleted successfully: $invoiceNumber');
    } catch (e) {
      debugPrint('Error deleting sale: $e');
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> getSalesForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    debugPrint('Fetching sales for ${DateFormat('yyyy-MM-dd').format(date)}');

    return _database
        .child(baseUrl)
        .child('sales')
        .child(date.year.toString())
        .child(date.month.toString().padLeft(2, '0'))
        .child(date.day.toString().padLeft(2, '0'))
        .onValue
        .map((event) {
          if (event.snapshot.value == null) {
            debugPrint('No sales found for selected date');
            return [];
          }

          List<Map<String, dynamic>> sales = [];
          try {
            Map<dynamic, dynamic> salesData =
                event.snapshot.value as Map<dynamic, dynamic>;
            salesData.forEach((key, value) {
              if (value is Map) {
                Map<String, dynamic> saleMap = {};
                value.forEach((k, v) => saleMap[k.toString()] = v);
                saleMap['id'] = key;
                sales.add(saleMap);
              }
            });

            // Sort by timestamp in descending order
            sales.sort((a, b) {
              final aTime = a['timestamp'] ?? 0;
              final bTime = b['timestamp'] ?? 0;
              return bTime.compareTo(aTime);
            });

            debugPrint('Found ${sales.length} sales for selected date');
            return sales;
          } catch (e) {
            debugPrint('Error processing sales data: $e');
            return [];
          }
        });
  }

  Future<Map<String, dynamic>> getMonthlySalesSummary(DateTime date) async {
    try {
      final year = date.year.toString();
      final month = date.month.toString().padLeft(2, '0');

      final snapshot =
          await _database
              .child(baseUrl)
              .child('sales')
              .child(year)
              .child(month)
              .get();

      if (snapshot.value == null) {
        return {
          'totalSales': 0,
          'totalAmount': 0.0,
          'averageSaleAmount': 0.0,
          'dailyBreakdown': {},
        };
      }

      final Map<dynamic, dynamic> data =
          snapshot.value as Map<dynamic, dynamic>;

      List<Map<String, dynamic>> allSales = [];
      Map<String, double> dailyBreakdown = {};

      data.forEach((day, dayData) {
        if (dayData is Map) {
          dayData.forEach((invoice, saleData) {
            if (saleData is Map) {
              final sale = Map<String, dynamic>.from(saleData);
              allSales.add(sale);

              final dayKey = '$year-$month-$day';
              dailyBreakdown[dayKey] =
                  (dailyBreakdown[dayKey] ?? 0.0) +
                  (sale['totalAmount'] ?? 0.0).toDouble();
            }
          });
        }
      });

      final totalSales = allSales.length;
      final totalAmount = allSales.fold(
        0.0,
        (sum, sale) => sum + (sale['totalAmount'] ?? 0.0).toDouble(),
      );
      final averageSaleAmount = totalSales > 0 ? totalAmount / totalSales : 0.0;

      return {
        'totalSales': totalSales,
        'totalAmount': totalAmount,
        'averageSaleAmount': averageSaleAmount,
        'dailyBreakdown': dailyBreakdown,
      };
    } catch (e) {
      debugPrint('Error getting monthly sales summary: $e');
      rethrow;
    }
  }
}
