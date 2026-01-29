import 'package:flutter/material.dart';


class PeminjamanCard extends StatefulWidget {
final Map<String, dynamic> data;
final Function(String) onUpdate;


const PeminjamanCard({super.key, required this.data, required this.onUpdate});


@override
State<PeminjamanCard> createState() => _PeminjamanCardState();
}


class _PeminjamanCardState extends State<PeminjamanCard> {
bool expand = false;


Color colorStatus(String s) {
if (s == 'Disetujui') return const Color(0xff22C55E);
if (s == 'Ditolak') return const Color(0xffEF4444);
return const Color(0xffFACC15);
}


@override
Widget build(BuildContext context) {
final status = widget.data['status'];


return GestureDetector(
onTap: () => setState(() => expand = !expand),
child: Container(
margin: const EdgeInsets.only(bottom: 12),
padding: const EdgeInsets.all(14),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(14),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.05),
blurRadius: 10,
offset: const Offset(0, 4),
)
],
),
child: Column(
children: [
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
Text(widget.data['nama'],
style:
const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
const SizedBox(height: 2),
Text(widget.data['tanggal'],
style:
const TextStyle(fontSize: 11, color: Colors.grey)),
]),
Container(
padding:
const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
decoration: BoxDecoration(
color: colorStatus(status),
borderRadius: BorderRadius.circular(20),
),
child: Text(status,
style:
const TextStyle(color: Colors.white, fontSize: 11)),
)
],
),
if (expand) ...[
const Divider(height: 24),
if (widget.data['alat'].isNotEmpty)
Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: widget.data['alat'].entries
.map<Widget>((e) => Padding(
padding: const EdgeInsets.only(bottom: 4),
child: Text('${e.key} : ${e.value}',
style: const TextStyle(fontSize: 12)),
))
.toList(),
),
const SizedBox(height: 12),
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
const Text('Status :', style: TextStyle(fontSize: 12)),
if (status == 'Menunggu')
Row(children: [
IconButton(
icon: const Icon(Icons.check_circle,
color: Color(0xff22C55E)),
onPressed: () => dialog(true),
),
IconButton(
icon: const Icon(Icons.cancel,
color: Color(0xffEF4444)),
onPressed: () => dialog(false),
),
])
else
Text(status,
style: TextStyle(
fontWeight: FontWeight.bold,
color: colorStatus(status)))
],
)
]
],
),
),
);
}


void dialog(bool approve) {
showDialog(
context: context,
builder: (_) => AlertDialog(
title: const Text('Setujui Peminjaman'),
content: const Text('Apakah anda yakin?'),
actions: [
TextButton(
onPressed: () => Navigator.pop(context),
child: const Text('Tidak')),
ElevatedButton(
onPressed: () {
widget.onUpdate(approve ? 'Disetujui' : 'Ditolak');
Navigator.pop(context);
},
child: const Text('Ya'),
)
],
),
);
}
}