import 'package:flutter/material.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:permission_handler/permission_handler.dart';


class BluetoothPrintScreen extends StatefulWidget {
  const BluetoothPrintScreen({super.key});

  @override
  State<BluetoothPrintScreen> createState() => _BluetoothPrintScreenState();
}

class _BluetoothPrintScreenState extends State<BluetoothPrintScreen> {
  final PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    setState(() => _isScanning = true);

    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();

    printerManager.startScan(const Duration(seconds: 4));
    printerManager.scanResults.listen((devices) {
      setState(() {
        _devices = devices;
        _isScanning = false;
      });
    });
  }

  Future<void> _printTicket(PrinterBluetooth printer) async {
    printerManager.selectPrinter(printer);

    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    final List<int> ticket = [];

    ticket.addAll(generator.text('Tienda Online Jesús',
        styles: PosStyles(align: PosAlign.center, bold: true)));
    ticket.addAll(generator.text('-----------------------------'));
    ticket.addAll(generator.text('Producto: Paleta'));
    ticket.addAll(generator.text('Precio: \$2.00'));
    ticket.addAll(generator.text('Cantidad: 1'));
    ticket.addAll(generator.text('-----------------------------'));
    ticket.addAll(generator.text('Gracias por tu compra!',
        styles: PosStyles(align: PosAlign.center)));
    ticket.addAll(generator.feed(2));
    ticket.addAll(generator.cut());

    final result = await printerManager.printTicket(ticket);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Resultado: ${result.msg}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Impresión por Bluetooth')),
      body: _isScanning
          ? const Center(child: CircularProgressIndicator())
          : _devices.isEmpty
              ? const Center(child: Text('No se encontraron dispositivos'))
              : ListView.builder(
                  itemCount: _devices.length,
                  itemBuilder: (context, index) {
                    final device = _devices[index];
                    return ListTile(
                      title: Text(device.name ?? 'Sin nombre'),
                      subtitle: Text(device.address ?? 'Sin dirección'),
                      trailing: ElevatedButton(
                        onPressed: () => _printTicket(device),
                        child: const Text('Imprimir'),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startScan,
        child: const Icon(Icons.refresh),
        tooltip: 'Escanear de nuevo',
      ),
    );
  }
}
