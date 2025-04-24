import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/printer_controller.dart';

class PrintSettingsView extends StatelessWidget {
  const PrintSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final PrinterController controller = Get.put(PrinterController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Printer Settings'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bluetooth Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Bluetooth Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Obx(() => Switch(
                          value: controller.isBluetoothEnabled.value,
                          onChanged: controller.toggleBluetooth,
                        )),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Obx(() => ElevatedButton.icon(
                      onPressed: controller.isBluetoothEnabled.value ? controller.scanDevices : null,
                      icon: const Icon(Icons.search),
                      label: Text(controller.isScanning.value ? 'Scanning...' : 'Scan for Devices'),
                    )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Connected Printer Info
            Obx(() {
              if (controller.isConnected.value) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Connected Printer',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Name: ${controller.deviceName.value}'),
                        Text('Address: ${controller.selectedPrinterAddress.value}'),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: controller.printTestPage,
                              icon: const Icon(Icons.print),
                              label: const Text('Test Print'),
                            ),
                            ElevatedButton.icon(
                              onPressed: controller.disconnectPrinter,
                              icon: const Icon(Icons.link_off),
                              label: const Text('Disconnect'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            
            const SizedBox(height: 16),
            
            // Available Devices List
            const Text(
              'Available Devices',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Use Expanded with a ListView for the devices list
            Expanded(
              child: Obx(() {
                if (controller.devices.isEmpty) {
                  return const Center(
                    child: Text('No Bluetooth printers found'),
                  );
                }
                
                return ListView.builder(
                  itemCount: controller.devices.length,
                  itemBuilder: (context, index) {
                    final device = controller.devices[index];
                    final isSelected = device.macAdress == controller.selectedPrinterAddress.value;
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.print),
                        title: Text(device.name ?? 'Unknown Device'),
                        subtitle: Text(device.macAdress ?? 'No address'),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : const Icon(Icons.radio_button_unchecked),
                        onTap: () => controller.connectToPrinter(device.macAdress!, device.name ?? 'Unknown Device'),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
} 