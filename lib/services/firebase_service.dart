import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum ENVIRONMENT { dev, prod }

const environment = ENVIRONMENT.prod;

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

  // Get sales data by date range
  Stream<List<Map<String, dynamic>>> getSalesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    // Create a stream controller to manage the stream
    final controller = StreamController<List<Map<String, dynamic>>>();
    
    // Map to store all sales data
    final Map<String, Map<String, dynamic>> allSalesMap = {};
    
    // List of subscriptions to clean up later
    final List<StreamSubscription> subscriptions = [];
    
    // Function to update the stream with current data
    void updateStream() {
      final List<Map<String, dynamic>> allSales = allSalesMap.values.toList();
      
      // Sort sales by timestamp in descending order
      allSales.sort((a, b) {
        final aTime = a['timestamp'] ?? 0;
        final bTime = b['timestamp'] ?? 0;
        return bTime.compareTo(aTime);
      });
      
      // Add the sales data to the stream
      controller.add(allSales);
    }
    
    // Set up listeners for each day in the range
    for (
      DateTime date = startDate;
      date.isBefore(endDate.add(const Duration(days: 1)));
      date = date.add(const Duration(days: 1))
    ) {
      final year = date.year.toString();
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      final dateKey = '$year-$month-$day';
      
      // Create a reference to this day's sales
      final dayRef = _database
          .child(baseUrl)
          .child('sales')
          .child(year)
          .child(month)
          .child(day);
      
      // Listen for changes to this day's sales
      final subscription = dayRef.onValue.listen(
        (event) {
          if (event.snapshot.value == null) {
            // No sales for this day, remove any existing sales for this day
            allSalesMap.removeWhere((key, value) => value['date'] == dateKey);
            updateStream();
            return;
          }
          
          final Map<dynamic, dynamic> daySales = event.snapshot.value as Map<dynamic, dynamic>;
          
          // Process each sale for this day
          daySales.forEach((invoiceNumber, saleData) {
            if (saleData is Map) {
              final Map<String, dynamic> sale = Map<String, dynamic>.from(saleData);
              sale['date'] = dateKey;
              sale['invoiceNumber'] = invoiceNumber;
              
              // Add or update this sale in our map
              allSalesMap['$dateKey-$invoiceNumber'] = sale;
            }
          });
          
          // Update the stream with the latest data
          updateStream();
        },
        onError: (error) {
          debugPrint('Error listening to sales for $dateKey: $error');
        }
      );
      
      // Add this subscription to our list for cleanup
      subscriptions.add(subscription);
    }
    
    // Clean up resources when the stream is closed
    controller.onCancel = () {
      for (var subscription in subscriptions) {
        subscription.cancel();
      }
      controller.close();
    };
    
    return controller.stream;
  }

  // Calculate summary statistics from sales data
  Map<String, dynamic> calculateSalesSummary(List<Map<String, dynamic>> sales) {
    double totalSales = 0;
    int totalOrders = sales.length;
    double totalDiscounts = 0;

    for (var sale in sales) {
      totalSales += (sale['totalAmount'] ?? 0).toDouble();
      totalDiscounts += (sale['discounts'] ?? 0).toDouble();
    }

    return {
      'totalSales': totalSales,
      'totalOrders': totalOrders,
      'totalDiscounts': totalDiscounts,
      'netTotal': totalSales - totalDiscounts,
    };
  }

  Stream<List<Map<String, dynamic>>> getItems() {
    debugPrint('Fetching items...');
    return _database.child(baseUrl).child('items').onValue.map((event) {
      if (event.snapshot.value == null) {
        debugPrint('No items found');
        return [];
      }

      List<Map<String, dynamic>> items = [];
      try {
        Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          if (value is Map) {
            Map<String, dynamic> item = {
              'id': key,
              'name': value['name'],
              'createdAt': value['createdAt'],
            };
            items.add(item);
          }
        });
      } catch (e) {
        debugPrint('Error processing items data: $e');
      }

      // Sort by creation date
      items.sort((a, b) {
        final aTime = a['createdAt'] ?? 0;
        final bTime = b['createdAt'] ?? 0;
        return bTime.compareTo(aTime);
      });

      debugPrint('Found ${items.length} items');
      return items;
    });
  }

  Future<void> addItem(Map<String, dynamic> itemData) async {
    try {
      final itemsRef = _database.child(baseUrl).child('items');
      await itemsRef.push().set(itemData);
      debugPrint('Item added successfully');
    } catch (e) {
      debugPrint('Error adding item: $e');
      rethrow;
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _database.child(baseUrl).child('items').child(id).remove();
      debugPrint('Item deleted successfully: $id');
    } catch (e) {
      debugPrint('Error deleting item: $e');
      rethrow;
    }
  }
}
