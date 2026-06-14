import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io_client;

void main() {
  runApp(const QueueCureApp());
}

class QueueCureApp extends StatelessWidget {
  const QueueCureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Queue Cure '26",
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xff0F172A), 
        cardColor: const Color(0xff1E293B), 
      ),
      home: const MainLayoutShell(),
    );
  }
}

class MainLayoutShell extends StatefulWidget {
  const MainLayoutShell({super.key});

  @override
  State<MainLayoutShell> createState() => _MainLayoutShellState();
}

class _MainLayoutShellState extends State<MainLayoutShell> {
  late io_client.Socket socket;
  int _currentSidebarIndex = 0;
  
  String activeToken = "NONE";
  String nextToken = "NONE ACTIVE";
  bool isConnected = false;
  List<String> activePatientQueue = []; 

  int avgConsultancyTime = 12; 
  int totalPatientsServed = 0;

  bool _isCallNextLoading = false; 

  final TextEditingController nameController = TextEditingController();
  final TextEditingController timeController = TextEditingController(); 

  @override
  void initState() {
    super.initState();
    timeController.text = avgConsultancyTime.toString();
    _initSocket();
  }

  void _initSocket() {
    socket = io_client.io('https://reentry-envoy-component.ngrok-free.dev', <String, dynamic>{
      'transports': ['websocket', 'polling'],
      'autoConnect': true,
    });

    socket.on('queue_update', (data) {
      if (mounted && data != null) {
        setState(() {
          activeToken = data['activeToken']?.toString() ?? 'NONE';
          nextToken = data['nextToken']?.toString() ?? 'NONE ACTIVE';
          
          if (data['patientQueue'] != null) {
            activePatientQueue = List<String>.from(
              data['patientQueue'].map((item) => item.toString()),
            );
          } else {
            activePatientQueue = [];
          }
          
          if (activeToken != "NONE" && activeToken != "NONE ACTIVE") {
            totalPatientsServed = int.tryParse(activeToken) ?? 0;
          }
        });
      }
    });

    socket.onConnect((_) {
      if (mounted) {
        setState(() => isConnected = true);
      }
    });

    socket.onDisconnect((_) {
      if (mounted) {
        setState(() => isConnected = false);
      }
    });
  }

  void _handleCallNextWithProtection() async {
    if (_isCallNextLoading) return; 

    setState(() {
      _isCallNextLoading = true; 
    });

    socket.emit('call_next');

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isCallNextLoading = false; 
      });
    }
  }

  @override
  void dispose() {
    socket.disconnect();
    nameController.dispose();
    timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              Container(
                width: 260,
                decoration: const BoxDecoration(
                  color: Color(0xff0F172A),
                  border: Border(
                    right: BorderSide(color: Color(0xff334155), width: 1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        "Queue Cure '26",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Divider(color: Color(0xff334155), height: 1),
                    const SizedBox(height: 16),
                    _buildSidebarTile(Icons.dashboard_rounded, "Dashboard", 0),
                    _buildSidebarTile(Icons.people_alt_rounded, "Patients", 1),
                    _buildSidebarTile(Icons.settings_rounded, "Settings", 2),
                  ],
                ),
              ),

              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 70,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xff334155), width: 1),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _currentSidebarIndex == 0 ? "Dashboard" : _currentSidebarIndex == 1 ? "Patients" : "Settings",
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isConnected ? const Color(0xff10B981).withAlpha(38) : Colors.red.withAlpha(38),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isConnected ? const Color(0xff10B981) : Colors.red,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: isConnected ? const Color(0xff10B981) : Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isConnected ? "Live Sync Active" : "Disconnected",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isConnected ? const Color(0xff10B981) : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: IndexedStack(
                        index: _currentSidebarIndex,
                        children: [
                          _buildDashboardView(),
                          _buildPatientsView(),
                          _buildSettingsView(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (!isConnected)
            Positioned.fill(
              child: Container(
                color: const Color(0xff0F172A).withAlpha(200),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: const Color(0xff1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.redAccent.withAlpha(100), width: 1.5),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          height: 40,
                          width: 40,
                          child: CircularProgressIndicator(color: Colors.redAccent, strokeWidth: 3),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Clinic Network Bridge Offline",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Please ensure your node terminal is active via 'node server.js'\nAttempting background synchronization link...",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.white38),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDashboardView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              _buildMetricCard("Avg Consultancy Time", "$avgConsultancyTime Mins", Icons.timer_rounded),
              const SizedBox(width: 16),
              _buildMetricCard("Est. Total Wait Time", "${activePatientQueue.length * avgConsultancyTime} Mins", Icons.hourglass_top_rounded),
              const SizedBox(width: 16),
              _buildMetricCard("Total Served Today", "$totalPatientsServed Patients", Icons.done_all_rounded),
            ],
          ),
          const SizedBox(height: 24),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Card(
                      elevation: 0,
                      color: const Color(0xff1E293B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xff334155)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Add Patient to System",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            
                            TextField(
                              controller: nameController,
                              decoration: InputDecoration(
                                hintText: "Enter full patient name",
                                hintStyle: const TextStyle(color: Colors.white38),
                                filled: true,
                                fillColor: const Color(0xff0F172A),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xff334155)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xff10B981)),
                                ),
                              ),
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            
                            TextField(
                              controller: timeController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: "Consultancy time in min",
                                suffixText: "mins",
                                suffixStyle: const TextStyle(color: Color(0xff10B981)),
                                filled: true,
                                fillColor: const Color(0xff0F172A),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xff334155)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xff10B981)),
                                ),
                              ),
                              style: const TextStyle(color: Colors.white),
                              onChanged: (val) {
                                final parsedTime = int.tryParse(val);
                                if (parsedTime != null && parsedTime > 0) {
                                  setState(() {
                                    avgConsultancyTime = parsedTime;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 24),
                            
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff10B981),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () {
                                  if (nameController.text.isNotEmpty) {
                                    socket.emit('add_patient', {'name': nameController.text});
                                    nameController.clear();
                                  }
                                },
                                child: const Text("Add Patient", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    Card(
                      elevation: 0,
                      color: const Color(0xff1E293B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xff334155)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Queue Control Console",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: _isCallNextLoading ? const Color(0xff334155) : const Color(0xff10B981), 
                                    width: 1.5,
                                  ),
                                  foregroundColor: _isCallNextLoading ? Colors.white24 : const Color(0xff10B981),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: _isCallNextLoading ? null : _handleCallNextWithProtection, 
                                child: _isCallNextLoading 
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white38),
                                      )
                                    : const Text("Call Next Token", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              Expanded(
                flex: 2,
                child: Card(
                  elevation: 0,
                  color: const Color(0xff1E293B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xff334155)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "NOW SERVING",
                          style: TextStyle(fontSize: 14, letterSpacing: 2, fontWeight: FontWeight.w800, color: Colors.white54),
                        ),
                        const SizedBox(height: 16),
                        
                        SizedBox(
                          height: 100,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return ScaleTransition(scale: animation, child: FadeTransition(opacity: animation, child: child));
                            },
                            child: Text(
                              activeToken != "NONE" ? "T-$activeToken" : "NONE",
                              key: ValueKey<String>(activeToken), 
                              style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w900, color: Color(0xff10B981)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Divider(color: Color(0xff334155)),
                        const SizedBox(height: 16),
                        const Text(
                          "UP NEXT",
                          style: TextStyle(fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.w700, color: Colors.white38),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          nextToken,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatientsView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Card(
        elevation: 0,
        color: const Color(0xff1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xff334155)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Active Waiting Registry",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Total Patients Waiting: ${activePatientQueue.length}",
                        style: const TextStyle(fontSize: 14, color: Colors.white38),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xff0F172A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xff334155)),
                    ),
                    child: Text(
                      "Est. Delay: ${activePatientQueue.length * avgConsultancyTime} mins",
                      style: const TextStyle(color: Color(0xff10B981), fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: activePatientQueue.isEmpty
                    ? const Center(
                        child: Text(
                          "No Active Patients in Queue",
                          style: TextStyle(color: Colors.white38, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: activePatientQueue.length,
                        itemBuilder: (context, index) {
                          final pName = activePatientQueue[index];
                          final waitTime = index * avgConsultancyTime;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            decoration: BoxDecoration(
                              color: const Color(0xff0F172A),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xff334155)),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xff10B981).withAlpha(30),
                                child: Text(
                                  "${index + 1}",
                                  style: const TextStyle(color: Color(0xff10B981), fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(
                                pName,
                                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                              trailing: Text(
                                "Est. Wait: ${waitTime}m",
                                style: const TextStyle(color: Colors.white38, fontSize: 13),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Card(
        elevation: 0,
        color: const Color(0xff1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xff334155)),
        ),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              "Submission & Compliance Architecture Rules",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              "System parameters required to pass internal project validation.",
              style: TextStyle(fontSize: 14, color: Colors.white38),
            ),
            const SizedBox(height: 24),
            
            _buildRuleTile("Rule 1: Sequential Allocation", "Tokens must follow continuous natural sequencing strictly starting from 1 with zero drops."),
            _buildRuleTile("Rule 2: Dynamic Wait Mapping", "Waiting registry metrics must auto-recalculate estimations dynamically using current array states."),
            _buildRuleTile("Rule 3: Non-Persistent Cache Flushing", "Hard resets must drop entire socket buffer memory stacks cleanly without leaking states."),
            _buildRuleTile("Rule 4: State Preservation", "Real-time navigation switching across the sidebar rail must preserve active web pipelines seamlessly."),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(color: Color(0xff334155)),
            ),
            
            const Text(
              "Operational Bench Control",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text("Flush Queue History"),
              subtitle: const Text("Flushes active server arrays instantly across all nodes"),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: () {
                  socket.emit('reset_queue');
                },
                child: const Text("Flush Queue", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xff1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xff334155)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xff10B981), size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleTile(String ruleNum, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_user_rounded, color: const Color(0xff10B981).withAlpha(200), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ruleNum, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(color: Colors.white54, fontSize: 13)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSidebarTile(IconData icon, String title, int index) {
    final bool isSelected = _currentSidebarIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? const Color(0xff10B981) : Colors.white54),
      title: Text(
        title,
        style: TextStyle(color: isSelected ? Colors.white : Colors.white54, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
      ),
      selected: isSelected,
      onTap: () {
        setState(() {
          _currentSidebarIndex = index;
        });
      },
    );
  }
}
