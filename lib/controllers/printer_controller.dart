import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

  final String PRINTER_ADDRESS_KEY = 'selected_printer_address';


class PrinterController extends GetxController {
  
  // Bluetooth state variables
  final RxBool isBluetoothEnabled = false.obs;
  final RxList<BluetoothInfo> devices = <BluetoothInfo>[].obs;
  final RxString selectedPrinterAddress = ''.obs;
  final RxBool isScanning = false.obs;
  final RxBool isConnected = false.obs;
  final RxString deviceName = ''.obs;
  final RxBool hasPermissions = false.obs;
  final RxBool isConnecting = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeBluetoothState();
    loadSavedPrinter();
  }

  Future<void> loadSavedPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    selectedPrinterAddress.value = prefs.getString(PRINTER_ADDRESS_KEY) ?? '';
    isConnected.value = selectedPrinterAddress.value.isNotEmpty;
  }

  Future<void> savePrinterAddress(String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PRINTER_ADDRESS_KEY, address);
  }

  Future<void> _initializeBluetoothState() async {
    try {
      hasPermissions.value = await checkBluetoothPermissions();

      if (!hasPermissions.value) {
        await requestBluetoothPermissions();
        return;
      }

      await initPlatformState();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error initializing Bluetooth state',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<bool> checkBluetoothPermissions() async {
    final bluetoothStatus = await Permission.bluetooth.status;
    final bluetoothScanStatus = await Permission.bluetoothScan.status;
    final bluetoothConnectStatus = await Permission.bluetoothConnect.status;
    final bluetoothAdvertiseStatus = await Permission.bluetoothAdvertise.status;
    final locationStatus = await Permission.location.status;

    return bluetoothStatus.isGranted &&
        bluetoothScanStatus.isGranted &&
        bluetoothConnectStatus.isGranted &&
        bluetoothAdvertiseStatus.isGranted &&
        locationStatus.isGranted;
  }

  Future<void> requestBluetoothPermissions() async {
    try {
      final statuses = await [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
        Permission.location,
      ].request();

      final allGranted = statuses.values.every((status) => status.isGranted);
      hasPermissions.value = allGranted;

      if (allGranted) {
        await initPlatformState();
      } else {
        Get.dialog(
          AlertDialog(
            title: const Text('Permissions Required'),
            content: const Text(
                'This app needs Bluetooth and location permissions to connect to printers. '
                'Please grant these permissions in Settings to use the printing features.'),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Get.back(),
              ),
              TextButton(
                child: const Text('Open Settings'),
                onPressed: () async {
                  Get.back();
                  await openAppSettings();
                  final newPermissions = await checkBluetoothPermissions();
                  if (newPermissions) {
                    hasPermissions.value = true;
                    await initPlatformState();
                  }
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error requesting Bluetooth permissions',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> initPlatformState() async {
    if (!hasPermissions.value) {
      return;
    }

    try {
      isScanning.value = true;
      final bool isOn = await PrintBluetoothThermal.bluetoothEnabled;
      isBluetoothEnabled.value = isOn;

      if (isBluetoothEnabled.value) {
        await scanDevices();
      } else {
        devices.clear();
        selectedPrinterAddress.value = "";
        deviceName.value = "";
        isConnected.value = false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error initializing Bluetooth',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isScanning.value = false;
    }
  }

  Future<void> scanDevices() async {
    if (!isBluetoothEnabled.value) {
      Get.snackbar(
        'Bluetooth Error',
        'Please enable Bluetooth to scan for devices',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isScanning.value = true;
    devices.clear();

    try {
      final List<BluetoothInfo> foundDevices = await PrintBluetoothThermal.pairedBluetooths;
      
      // Filter for printer devices
      final filteredDevices = foundDevices
          .where((device) => device.name.toLowerCase().contains("printer"))
          .toList();
      
      devices.assignAll(filteredDevices);
      
      if (filteredDevices.isEmpty) {
        Get.snackbar(
          'No Printers Found',
          'No Bluetooth printers were found. Make sure your printer is turned on and paired with this device.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to scan for devices: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isScanning.value = false;
    }
  }

  Future<void> connectToPrinter(String address, String name) async {
    if (isConnecting.value) return;
    
    isConnecting.value = true;
    
    try {
      // First, disconnect from any existing connection
      if (isConnected.value) {
        await disconnectPrinter();
      }
      
      // Show connecting dialog
      Get.dialog(
        AlertDialog(
          title: const Text('Connecting...'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Connecting to $name...'),
            ],
          ),
        ),
        barrierDismissible: false,
      );
      
      // Try to connect with a timeout
      bool connectionResult = false;
      try {
        // Add a small delay before connecting
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Try to connect
        connectionResult = await PrintBluetoothThermal.connect(macPrinterAddress: address);
        
        // Log the connection result
        debugPrint('Connection result: $connectionResult');
        
        // If connection failed, try one more time after a short delay
        if (!connectionResult) {
          await Future.delayed(const Duration(seconds: 1));
          connectionResult = await PrintBluetoothThermal.connect(macPrinterAddress: address);
          debugPrint('Second connection attempt result: $connectionResult');
        }
      } catch (e) {
        debugPrint('Connection error: $e');
        Get.back(); // Close the connecting dialog
        Get.snackbar(
          'Connection Error',
          'Failed to connect: $e',
          snackPosition: SnackPosition.BOTTOM,
        );
        isConnecting.value = false;
        return;
      }
      
      // Close the connecting dialog
      Get.back();
      
      if (connectionResult) {
        selectedPrinterAddress.value = address;
        deviceName.value = name;
        isConnected.value = true;
        await savePrinterAddress(address);
        Get.snackbar(
          'Success',
          'Connected to printer successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Connection Failed',
          'Could not connect to the printer. Please make sure it is turned on and in range.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error connecting to printer: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isConnecting.value = false;
    }
  }

  Future<void> disconnectPrinter() async {
    try {
      await PrintBluetoothThermal.disconnect;
      selectedPrinterAddress.value = "";
      deviceName.value = "";
      isConnected.value = false;
      Get.snackbar(
        'Success',
        'Disconnected from printer',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error disconnecting from printer: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> printTestPage() async {
    if (!isConnected.value) {
      Get.snackbar(
        'Error',
        'Please connect to a printer first',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      // Initialize printer
      await PrintBluetoothThermal.writeBytes([
        0x1B, 0x40, // Initialize printer
        0x1B, 0x61, 0x01, // Center alignment
        0x1B, 0x45, 0x01, // Bold on
      ]);
      
      // Print test content
      final text = "=== Test Print ===\n\n"
          "This is a test print from Mobile ERP\n\n"
          "Time: ${DateTime.now()}\n"
          "================\n\n\n\n";
      
      await PrintBluetoothThermal.writeBytes(text.codeUnits);
      
      Get.snackbar(
        'Success',
        'Test print sent successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to print: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void toggleBluetooth(bool value) async {
    if (value) {
      await initPlatformState();
    } else {
      isBluetoothEnabled.value = false;
      devices.clear();
      selectedPrinterAddress.value = "";
      deviceName.value = "";
      isConnected.value = false;
    }
  }
}